class PackagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction, :approvable, :rejectable, :package_type

  # GET /packages
  # GET /packages.json
  def index
    if params[:batch_id]
      @batch = Batch.find(params[:batch_id])
      @packages = @batch.packages.order("#{sort_column} #{sort_direction}").page(params[:page])
    else
      @packages = Package.order("#{sort_column} #{sort_direction}").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @packages }
    end
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
    @tasks = @package.tasks.in_progress.order("status_id desc").page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @package }
    end
  end

  # GET /packages/new
  # GET /packages/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @package }
    end
  end

  # GET /packages/1/edit
  def edit
  end

  # POST /packages
  # POST /packages.json
  def create
    respond_to do |format|
      if @package.save
        format.html { redirect_to @package, notice: 'Package was successfully created.' }
        format.json { render json: @package, status: :created, location: @package }
      else
        format.html { render action: "new" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /packages/1
  # PUT /packages/1.json
  def update
    respond_to do |format|
      if @package.update_attributes(params[:package])
        format.html { redirect_to @package, notice: 'Package was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.json
  def destroy
    @package.destroy

    respond_to do |format|
      format.html { redirect_to packages_url }
      format.json { head :no_content }
    end
  end

  def approve
    @package = Package.find(params[:id])
    authorize! :approve, @package
    @package.update_attributes(:status_id => Status.approved.id)

    respond_to do |format|
      format.html { redirect_to batch_url(@package.batch_id) }
      format.json { head :no_content }
    end
  end

  def reject
    @package = Package.find(params[:id])
    authorize! :reject, @package
    @package.update_attributes(:status_id => Status.rejected.id)

    respond_to do |format|
      format.html { redirect_to batch_url(@package.batch_id) }
      format.json { head :no_content }
    end
  end

  private

  def sort_column
    Package.column_names.include?(params[:sort]) ? params[:sort] : "sip_path"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def approvable(package)
    [
      Status.approved,
      Status.rejected,
      Status.awaiting_approval,
      Status.under_review,
    ].map { |s| s.id }.
      include?(package.status_id)
  end

  def rejectable(package)
    approvable(package)
  end

  def package_type(package)
    types = []
    types << Batch.find(package.batch_id).batch_type.name
    types << 'oral history' if package.oral_history?
    types << 'dark archive' if package.dark_archive?
    types << 'online' if package.online?
    types.join(', ')
  end
end
