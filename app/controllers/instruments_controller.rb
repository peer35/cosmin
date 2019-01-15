class InstrumentsController < ApplicationController
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  before_action :require_user_authentication_provider
  before_action :verify_user

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
    @instruments, @alphaParams = Instrument.all.order('LOWER(name) ASC')
                                     .alpha_paginate(params[:letter], {:default_field => '0-9', :include_all => false, :js => false, :bootstrap3 => true}){|instrument| instrument.name}
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
        format.html {redirect_to instruments_url, notice: 'Instrument was successfully created.'}
        format.json {render :show, status: :created, location: @instrument}
      else
        format.html {render :new}
        format.json {render json: @instrument.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /instruments/1
  # PATCH/PUT /instruments/1.json
  def update
    # serialize reference here!
    respond_to do |format|
      if @instrument.update(instrument_params)
        format.html {redirect_to instruments_url, notice: 'Instrument was successfully updated.'}
        format.json {render :show, status: :ok, location: @instrument}
      else
        format.html {render :edit}
        format.json {render json: @instrument.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /instruments/1
  # DELETE /instruments/1.json
  def destroy
    @instrument.destroy
    respond_to do |format|
      format.html {redirect_to instruments_url, notice: 'Instrument was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def instrument_params
    params.require(:instrument).permit(:name, :reference, :doi, :pmid, :refurl, :url1, :url2, :url3)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end