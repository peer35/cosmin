class InstrumentsController < ApplicationController
  require 'csv'
  require 'caxlsx'

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  before_action :require_user_authentication_provider
  before_action :verify_user

  # update the cache for the table when changes have happened, this is cheaper than just rebuilding the whole datastructure
  after_action :update_table_cache, only: [:create, :update, :destroy]


  def verify_user
    if current_user.to_s.blank?
      flash[:notice] = I18n.t('admin.need_login') and raise Blacklight::Exceptions::AccessDenied
    elsif Rails.configuration.x.admin_users_email.include? current_user.email
    else
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /instruments/instrument/table
  def table
    respond_to do |format|
      format.json do
        ins_data = update_table_cache(false)
        render :json => {data: ins_data}
      end
    end
  end

  # GET /instruments
  # GET /instruments.json
  def index
    respond_to do |format|
      format.csv do
        send_data to_csv, filename: "instruments-#{Date.today}.csv"
      end

      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="instruments-' + Date.today.to_s + '.xlsx"'
      }

      format.html do
        @name=params[:name]
        render :index
      end

      format.json do
        @instruments = Instrument.where("name ILIKE ?", "%#{params[:term]}%").map { |instrument| {:id => instrument.id, :text => instrument.name} }
        render :json => @instruments
      end

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
        format.html { redirect_to instruments_url(anchor: @instrument.id, name: @instrument.name), notice: 'Instrument was successfully created.' }
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
        format.html { redirect_to instruments_url(anchor: @instrument.id, name: @instrument.name), notice: 'Instrument was successfully updated.' }
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
    @instrument.destroy
    respond_to do |format|
      format.html { redirect_to instruments_url(name: @instrument.name), notice: 'Instrument was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def update_table_cache(changes = true)
    table_key = "instrumentstable"
    expire_in = 1.day
    data = Rails.cache.read(table_key)
    if data.nil?
      data = Instrument.all.order('LOWER(name) ASC').map { |instrument|
        cache_record(instrument)
      }
      Rails.cache.write(table_key, data, :expires_in => expire_in)
    elsif changes # one record changed and cache already filled, do not rerun query but use existing cache as base
      Rails.cache.delete(table_key)
      id = @instrument.id
      logger.info "********************* #{action_name} on #{id}"
      old_data = data
      data = []
      old_data.each do |ins|
        logger.info(ins[:id])
        if ins[:id] == id
          unless action_name == 'destroy'
            data.append(cache_record(@instrument))
          end
        else
          data.append(ins)
        end
      end
      if action_name == 'create'
        data.append(cache_record(@instrument))
      end
      Rails.cache.write(table_key, data, :expires_in => expire_in)
    end
    return data
  end

  def cache_record(instrument)
    return {
        :id => instrument.id,
        :name => instrument.name.strip,
        :url1 => instrument.url1 || "",
        :url2 => instrument.url2 || "",
        :url3 => instrument.url3 || "",
        :count => instrument.records.count,
        :status => instrument.status || "",
        :edit => view_context.link_to('Edit', edit_instrument_path(instrument)),
        :delete => view_context.link_to('Delete', instrument, method: :delete, data: {confirm: 'Are you sure?'})
    }
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