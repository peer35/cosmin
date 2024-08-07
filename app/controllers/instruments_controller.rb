class InstrumentsController < ApplicationController
  require 'csv'
  require 'caxlsx'

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  before_action :require_user_authentication_provider, except: [:search]
  before_action :verify_user, except: [:search]

  helper_method :startletter

  def verify_user
    if current_user.to_s.blank?
      flash[:notice] = I18n.t('admin.need_login') and raise Blacklight::Exceptions::AccessDenied
    elsif Rails.configuration.x.admin_users_email.include? current_user.email
    else
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /instruments
  # GET /instruments.json
  def index
    # @instruments = Instrument.all.order('LOWER(name) ASC')
    # @users, @alphaParams = User.all.alpha_paginate(params[:letter]){|user| user.name}
    respond_to do |format|
      format.csv do
        send_data to_csv, filename: "instruments-#{Date.today}.csv"
      end

      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="instruments-' + Date.today.to_s + '.xlsx"'
      }

      format.html do
        if params[:letter].nil? or params[:letter]=='0-9'
          exp="name ~ '^[0-9]'"
        elsif params[:letter]=='*'
          exp="name ~ '^[^a-zA-Z0-9]'"
        else
          exp="LOWER(name) LIKE ?", "#{params[:letter].downcase}%"
        end
        instrument_selection = Instrument.select('instruments.*, count(record_id) as count_records')
                                         .where(exp)
                                         .left_outer_joins(:records)
                                         .group('instruments.id')
                                         .order('LOWER(name) ASC')

        @instruments, @alphaParams = instrument_selection
                                         .alpha_paginate(params[:letter], {:default_field => '0-9', :include_all => false, :paginate_all => true, :js => false, :bootstrap3 => true}) { |instrument| instrument.name }
        @alphaParams[:availableLetters]=['0-9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','*']
        #@instruments.sort_by! { |m| m.name.downcase }
      end


      format.json do
        @instruments = Instrument.where("name ILIKE ?", "%#{params[:term]}%").map { |instrument| {:id => instrument.id, :text => instrument.name} }
        render :json => @instruments
      end

    end
  end

  # GET instrument/:id
  def search
    begin
      @instrument = Instrument.find(params[:id])
        # TODO use controller action
        redirect_to '/?f[instrument_sm][]=' + @instrument.name
    rescue ActiveRecord::ActiveRecordError
      	redirect_to :controller => 'catalog', action: "index"
        flash[:error] = "Instrument not found"
    end
  end

  # GET /instruments/1
  # GET /instruments/1.json
  def show
  end

  # GET /instruments/new
  def new
    @instrument = Instrument.new
  end

  # GET /instruments/1/edit
  def edit
    # unserialize reference
  end

  # POST /instruments
  # POST /instruments.json
  def create
    # serialize reference here!
    @instrument = Instrument.new(instrument_params)

    respond_to do |format|
      if @instrument.save
        format.html { redirect_to instruments_url(anchor: @instrument.id, letter: startletter), notice: 'Instrument was successfully created.' }
        format.json { render :show, status: :created, location: @instrument }
      else
        format.html { render :new }
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instruments/1
  # PATCH/PUT /instruments/1.json
  def update
    # serialize reference here!
    respond_to do |format|
      if @instrument.update(instrument_params)
        #format.html { redirect_to instruments_url(anchor: @instrument.id, letter: startletter), notice: 'Instrument was successfully updated.' }
        format.html { redirect_to instruments_url(letter: startletter), notice: 'Instrument was successfully updated.' }
        format.json { render :show, status: :ok, location: @instrument }
      else
        format.html { render :edit }
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instruments/1
  # DELETE /instruments/1.json
  def destroy
    s = startletter
    @instrument.destroy
    respond_to do |format|
      format.html { redirect_to instruments_url(letter: s), notice: 'Instrument was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def startletter
    if @instrument.name[0] =~ /[A-Za-z]/
      @instrument.name[0]
    elsif @instrument.name[0] =~ /[0-9]/
      '0-9'
    else
      '*'
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def instrument_params
    params.require(:instrument).permit(:name, :reference, :doi, :pmid, :refurl, :url1, :url2, :url3, :status)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end

def to_csv
  headers = ["number of records", "name", "reference", "doi", "pmid", "refurl", "url1", "url2", "url3", "created_at", "updated_at"]
  fields = ["name", "reference", "doi", "pmid", "refurl", "url1", "url2", "url3", "created_at", "updated_at"]

  CSV.generate(headers: true, :col_sep => ",") do |csv|
    csv << headers
    Instrument.all.each do |i|
      row = []
      row.append(i.records.count)
      fields.each do |f|
        if f == 'created_at' || f == 'updated_at'
          row.append(i[f].localtime.strftime('%F %R'))
        else
          row.append(i[f])
        end
      end


      csv << row
      row.clear
    end
  end
end