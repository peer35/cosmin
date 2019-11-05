require 'rsolr'

class Record < ApplicationRecord
  has_and_belongs_to_many :instruments, -> { distinct } do
    def << (value)
      super value rescue ActiveRecord::RecordNotUnique
    end
  end

  serialize :age, JSON
  serialize :bpv, JSON
  serialize :disease, JSON
  serialize :fs, JSON
  serialize :ghp, JSON
  serialize :oql, JSON
  serialize :pnp, JSON
  serialize :ss, JSON
  serialize :tmi, JSON
  serialize :author, JSON
  serialize :url, JSON
  serialize :instrument, JSON

  validates :title, presence: true
  validate :check_doubles, :on => :create

  has_paper_trail

  after_save :update_solr
  after_initialize :init

  before_destroy :delete_from_solr

  def init
    # set empty array for multivalued fields
    self.age ||= []
    self.bpv ||= []
    self.disease ||= []
    self.fs ||= []
    self.ghp ||= []
    self.oql ||= []
    self.pnp ||= []
    self.ss ||= []
    self.tmi ||= []
    self.instrument ||= []
    self.author ||= []
    self.url ||= []
    self.status ||= 'new'
  end

  def check_doubles
    # on title
    if !Record.where(:title => self.title, :pubyear => self.pubyear).blank?
      errors.add(:title, "already present in COSMIN database")
    end
    logger.debug '**********'
    logger.debug self.doi
    unless self.doi == '' or self.doi.nil?
      if !Record.where(:doi => self.doi).blank?
        errors.add(:doi, "already present in COSMIN database")
      end
    end
    unless self.endnum == '' or self.endnum.nil?
      if !Record.where(:endnum => self.endnum).blank?
        errors.add(:endnum, "endnote record number already present in COSMIN database")
      end
    end
  end

  def update_index
    # needed for indexall
    update_solr
  end
end

private

def update_solr
  record = self
  solr_config = Rails.application.config_for :blacklight
  @@solr = RSolr.connect :url => solr_config['url'] # get this from blacklight config

  if record.status == 'published'
    if record.author.length > 0
      first_author = record.author[0]
    else
      first_author = ''
    end

    instrument_list=[]
    instrument_presentation_list=[]
    record.instruments.order(name: :asc).each do |instrument|
      instrument_list.append(instrument.name.strip)
      instrument_presentation_list.append(instrument.to_json)
    end

    logger.info 'index ' + record.id.to_s

    @@solr.add :id => record.id,
               :endnum_i => record.endnum,
               :abstract_s => record.abstract,
               :accnum_s => record.accnum,
               :age_sm => record.age.sort!,
               :author_sm => record.author,
               :bpv_sm => record.bpv.sort!,
               :cu_b => record.cu,
               :disease_sm => record.disease.sort!,
               :doi_s => record.doi,
               :url_sm => record.url,
               :fs_sm => record.fs.sort!,
               :ghp_sm => record.ghp.sort!,
               :instrument_sm => instrument_list.sort_by {|k| k},
               :instrumentpresentation_sfm => instrument_presentation_list, # stored, not indexed
               :issn_s => record.issn,
               :issue_s => record.issue,
               :journal_s => record.journal,
               :oc_sm => record.oc,
               :oql_sm => record.oql.sort!,
               :pnp_sm => record.pnp.sort!,
               :pubyear_s => record.pubyear,
               :pub_date => record.pubyear,
               :ss_sm => record.ss.sort!,
               :startpage_s => record.startpage,
               :title_s => record.title,
               :tmi_sm => record.tmi.sort!,
               :author_sort => first_author,
               :weight_f => 1.0
    @@solr.commit
  else
    @@solr.delete_by_id(record.id)
    @@solr.commit
  end
  return true
end

def delete_from_solr
  record = self
  solr_config = Rails.application.config_for :blacklight
  logger.debug 'delete record from solr'
  @@solr = RSolr.connect :url => solr_config['url'] # get this from blacklight config
  @@solr.delete_by_id(record.id)
  @@solr.commit
end