class BatchesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction

  # GET /batches
  # GET /batches.json
  def index
    @batches = Batch.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @batches }
    end
  end

  # GET /batches/1
  # GET /batches/1.json
  def show
    #@packages = @batch.packages.where.not(status_id: Status.archived.id).not(status_id: Status.completed.id).order("status_id sort desc").page(params[:page])
    @packages = @batch.packages.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @batch }
    end
  end

  # GET /batches/new
  # GET /batches/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @batch }
    end
  end

  # GET /batches/1/edit
  def edit
  end

  # POST /batches
  # POST /batches.json
  def create
    @batch = Batch.new(params[:batch])

    respond_to do |format|
      if @batch.save
        format.html { redirect_to @batch, notice: 'Batch was successfully created.' }
        format.json { render json: @batch, status: :created, location: @batch }
      else
        format.html { render action: "new" }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /batches/1
  # PUT /batches/1.json
  def update
    respond_to do |format|
      if @batch.update_attributes(params[:batch])
        format.html { redirect_to @batch, notice: 'Batch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1
  # DELETE /batches/1.json
  def destroy
    @batch.destroy

    respond_to do |format|
      format.html { redirect_to batches_url }
      format.json { head :no_content }
    end
  end

  private

  def sort_column
    Batch.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
