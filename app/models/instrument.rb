class Instrument < ApplicationRecord
  has_and_belongs_to_many :records, -> { distinct } do
    def << (value)
      super value rescue ActiveRecord::RecordNotUnique
    end
  end

  after_initialize :init
  before_destroy :check_records, prepend: true

  validates :name, presence: true
  validate :check_doubles, :on => :create

  after_save :update_solr

  def check_doubles
    if !Instrument.where(:name => self.name).blank?
      errors.add(:name, "already present in COSMIN database instrument list")
    end
  end

  def init
  end

  def check_records
    logger.debug records.count
    return true if records.count == 0
    errors[:base] << "Cannot delete instrument with associated records"
    throw(:abort)
  end

  def update_solr
    # update associated SOLR records
    self.records.each do |record|
      record.delay.update_index
    end
  end
end
