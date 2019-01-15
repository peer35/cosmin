class RecordsController < ApplicationController
  # Duplicate key on id:
  #ALTER TABLE "records" RENAME COLUMN "id" TO "id_orig";
  #ALTER TABLE "records" ADD COLUMN "id" bigserial NOT NULL;
  #UPDATE "records" SET "id"="id_orig";
  #ALTER TABLE "records" DROP COLUMN "id_orig";
  #SELECT setval(pg_get_serial_sequence('records', 'id'), coalesce(max(id),1), false) FROM records;

  # these are callable from the Views
  helper_method :author_instrument_list, :catall, :sort_column, :sort_direction, :status_filter


  include Blacklight::Configurable
  include Blacklight::Catalog

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :set_record, only: [:show, :edit, :update, :destroy]

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

  # GET /records
  # GET /records.json
  def index
    # In case the user clicks the search button on a Records page
    unless params[:q].nil?
      redirect_to :controller => 'catalog', action: "index", q: params[:q]
    end

    #@records = Record.order('updated_at DESC, title').all()i
    @records = Record.where(:status => status_filter).order(sort_column + " " + sort_direction)

    # sent here after a ris file upload
    if params[:error_report]
      @error_report = params[:error_report]
    end
  end

  # GET /records/1
  # GET /records/1.json
  def show
    if @record.status=='published'
      redirect_to :controller => 'catalog', action: "show", id: @record.id
    else
      redirect_to action: "index"
    end
  end



  # GET /records/new
  def new
    logger.debug '>>>>>>> controller new'
    @record = Record.new
  end

  # GET /records/1/edit
  def edit
    @versions = @record.versions
    @current = @record
    @versionshowing = Hash.new()
    if params[:version]
      @record = @record.versions.find(params[:version]).reify
      @versionshowing['status'] = 'previous'
    else
      #@record.creationdate = Time.now
      @versionshowing['status'] = 'current'
    end
    @versionshowing['created_by'] = @record.user_email
    @versionshowing['created_at'] = @record.updated_at
  end

  # POST /records
  # POST /records.json
  def create
    record_params['author']=record_params['author_str'].split(';')
    record_params.delete('author_str')
    @record = Record.new(record_params)
    @record.user_email = current_user.email
    respond_to do |format|
      if @record.save
        if @record.status == 'published'
          flash[:notice] = "Record was successfully created."
          format.html {redirect_to :controller => 'catalog', action: "show", id: @record.id}
          format.json {render :show, status: :created, location: @record}
        else
          format.html {redirect_to records_url, notice: 'Record was successfully created.'}
          format.json {render :show, status: :ok, location: @record}
        end
      else
        format.html {render action: "new"}
        format.json {render json: @record.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      @record.user_email = current_user.email
      record_params['author']=record_params['author_str'].split(';')
      record_params.delete('author_str')
      logger.debug record_params
      if @record.update(record_params)
        if @record.status == 'published'
          flash[:notice] = "Record was successfully updated."
          format.html {redirect_to :controller => 'catalog', action: "show", id: @record.id}
          format.json {render :show, status: :ok, location: @record}
        else
          format.html {redirect_to records_url, notice: 'Record was successfully updated.'}
          format.json {render :show, status: :ok, location: @record}
        end
      else
        format.html {render :edit}
        format.json {render json: @record.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy
    respond_to do |format|
      format.html {redirect_to records_url(filter: params[:filter], sort: params[:sort], direction: params[:direction]), notice: 'Record was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  # GET /records/record/indexall
  def indexall
    respond_to do |format|
      Record.all.each do |record|
        record.update_index
      end
      flash[:notice] = 'Records reindexed.'
      format.html {redirect_to :controller => 'catalog', action: "index"}
    end
  end

  # uploading RIS files
  def upload
    respond_to do |format|
      uploaded_io = params[:upload_ris]
      File.open(Rails.root.join('tmp', 'uploads', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      error_file, messages = read_ris(Rails.root.join('tmp', 'uploads', uploaded_io.original_filename))

      File.delete(Rails.root.join('tmp', 'uploads', uploaded_io.original_filename))
      format.html {redirect_to records_url(error_report: 'uploads/' + error_file, filter: 'new'), notice: messages}
    end
  end

  # helper_method
  def author_instrument_list()
    list = {}
    authors = []
    Record.all.each do |record|
      record.author.each do |aut|
        unless authors.include? aut
          authors.append(aut)
        end
      end
      list['author'] = authors.sort_by {|k| k}
    end
    return list
  end

  # helper_method
  def catall
    if @cats.nil?
      @cats = {
          :age => Category.all.select {|c| c.cat == 'age'},
          :bpv => Category.all.select {|c| c.cat == 'bpv'},
          :disease => Category.all.order(:id).select {|c| c.cat == 'disease'},
          :fs => Category.all.select {|c| c.cat == 'fs'},
          :ghp => Category.all.select {|c| c.cat == 'ghp'},
          :oql => Category.all.select {|c| c.cat == 'oql'},
          :pnp => Category.all.select {|c| c.cat == 'pnp'},
          :ss => Category.all.select {|c| c.cat == 'ss'},
          :tmi => Category.all.order(:name).select {|c| c.cat == 'tmi'},
      }
    end
    return @cats
  end

  private

  def status_filter
    # dit kan vast handiger
    statuses = Category.all.select {|c| c.cat == 'status'}
    list = []
    statuses.each do |s|
      list.append(s.name)
    end
    list.include?(params[:filter]) ? params[:filter] : "in review"
  end

  def sort_column
    Record.column_names.include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def read_ris(filename)
    messages = []
    @record = Record.new
    @record.author = []
    @record.url = []
    n = 0
    added_count = 0
    error_count = 0
    errorlog = "Error report for RIS file " + filename.basename.to_s + "\n\n"
    text = File.open(filename).read
    text = text.force_encoding('UTF-8')
    text.gsub!("\r\n?".force_encoding('UTF-8'), "\n")
    text.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') # remove BOM
    text.each_line do |line|
      ris_field = line[0, 5]
      value = line[6, line.length]
      case ris_field
      when 'AB  -'
        @record.abstract = value.strip()
      when 'AN  -'
        @record.accnum = value.strip()
      when 'DO  -'
        @record.doi = value.strip()
      when 'ID  -'
        @record.endnum = value.strip()
      when 'IS  -'
        @record.issue = value.strip()
      when 'T2  -'
        @record.journal = value.strip()
      when 'PY  -'
        @record.pubyear = value.strip()
      when 'TI  -'
        @record.title = value.strip()
      when 'SN  -'
        @record.issn = value.strip()
      when 'SP  -'
        @record.startpage = value.strip()
      when 'AU  -'
        arr = value.strip().split(";")
        if arr.length > 1
          arr.each do |author|
            @record.author.append(author.strip())
          end
        else
          @record.author.append(value.strip())
        end
      when 'UR  -'
        @record.url.append(value.strip())
      when 'TY  -'
        logger.debug 'new record'
        n = n + 1
        if n > 1 #store record
          errorlog, added_count, error_count = store_ris_record(errorlog, added_count, error_count, filename)
          @record = nil
          @record = Record.new
          @record.author = []
          @record.url = []
        end
      end
    end
    #last record
    if n > 0
      errorlog, added_count, error_count = store_ris_record(errorlog, added_count, error_count, filename)
      logger.debug errorlog
    end
    error_file = Rails.root.join('public', 'uploads', 'errors_' + filename.basename.to_s)
    logger.debug error_file
    File.open(error_file, 'wb') do |file|
      file.write(errorlog)
    end
    return error_file.basename.to_s, 'Added ' + added_count.to_s + ' records. ' + error_count.to_s + ' failed records'
  end

  def store_ris_record(errorlog, added_count, error_count, filename)
    @record.admin_notes = 'Imported from ' + filename.basename.to_s
    @record.status = 'new'
    @record.user_email = current_user.email
    if @record.save
      added_count = added_count + 1
    else
      errors = @record.errors.full_messages
      errorlog << @record.title + " failed with error(s): \t"
      errors.each do |msg|
        errorlog << msg + " "
      end
      errorlog << "\n"
      error_count = error_count + 1
    end
    return errorlog, added_count, error_count
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = Record.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    #params.require(:record).permit(:cosmin_id, :abstract, :accnum, :author, :bpv, :cu, :disease, :doi, :fs, :ghp, :instrument, :issn, :issue, :journal, :oql, :pnp, :age, :pubyear, :ss, :startpage, :title, :tmi, :url, :user_email)
    # Pass empty array when no checkboxes were set in the form, otherwise nothing is passed and the record is not updated
    params[:record][:age] ||= []
    params[:record][:bpv] ||= []
    params[:record][:disease] ||= []
    params[:record][:fs] ||= []
    params[:record][:ghp] ||= []
    params[:record][:oql] ||= []
    params[:record][:pnp] ||= []
    params[:record][:ss] ||= []
    params[:record][:tmi] ||= []
    params[:record][:author] ||= []
    params[:record][:url] ||= []
    #params[:record][:instruments] ||= []
    params.require(:record).permit!
  end
end

def user_not_authorized
  flash[:alert] = "You are not authorized to perform this action."
  redirect_to(request.referrer || root_path)
end
