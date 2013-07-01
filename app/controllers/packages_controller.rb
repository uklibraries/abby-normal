class PackagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction, :inspection_link, :discussion_link

  # GET /packages
  # GET /packages.json
  def index
    @batch = Batch.find(params[:batch_id])
    @packages = @batch.packages.order("#{sort_column} #{sort_direction}").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @packages }
    end
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
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

  private

  def sort_column
    Package.column_names.include?(params[:sort]) ? params[:sort] : "sip_path"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  #def inspection_link(package)
  #  if package.dip_identifier
  #    batch = Batch.find(package.batch_id)
  #    type = BatchType.find(batch.batch_type_id).name
  #    test_site = 'http://kdl.kyvl.org/test/catalog'
  #    dip_id = package.dip_identifier + (['EAD', 'oral history'].include?(type) ? "" : "_1")
  #    "#{test_site}/#{dip_id}"
  #  end
  #end

  #def discussion_link(package)
  #  Batch.find(package.batch_id).discussion_link
  #end
end
