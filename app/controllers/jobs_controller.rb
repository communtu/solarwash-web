class JobsController < ApplicationController
  include ConflictHelper
  include ApplicationHelper
  # GET /jobs
  # GET /jobs.json
  def index    
    @jobs = Job.all.find_all{ |job| job.user_id == current_user.user_id }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @device = Device.find(params[:device_id])    
    @job = @device.jobs.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end
  
  def update_confirm
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:job_id])
    
    respond_to do |format|
      if !owner?(@job)
        flash[:error] = "Dazu hast du keine Berechtigung!"
        format.html { redirect_to root_path }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
      if @job.update_attribute('confirm',true)
        if @job.start.to_datetime < DateTime.now
          @job.update_attribute('start', DateTime.now)
          @job.update_attributes(:is_running => true)
          @device.update_attributes(:state => 2)
        end
          flash[:success] = "Auftrag wurde erfolgreich bestaetigt"
          format.html { redirect_to root_path }
          format.json { head :no_content }
      else
          flash[:error] = "Fehler bei dem Update"
          format.html { redirect_to root_path }
          format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /jobs/1/edit
  def edit
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @device = Device.find(params[:device_id])
    @job = @device.jobs.new(params[:job])
    
    @job.confirm = false  if @job.confirm == nil
    
    if @job.end_of_timespan != nil && !@job.end_of_timespan.is_a?(ActiveSupport::TimeWithZone)
      @job.end_of_timespan = DateTime.strptime(params[:job]['end_of_timespan'], '%d.%m.%Y %H:%M') - 1.hour
    end
    
    respond_to do |format|
      
      if @job.valid?
        if !ConflictHelper.conflict_management(@job, @device)
          @job.save
          flash[:success] = "Auftrag wurde erfolgreich angelegt"
          format.html { redirect_to root_path}
          format.json { render json: @job, status: :created, location: @job }
        else
          flash[:error] = JobsHelper.errormsg_end_of_timespan(@device.id, @job)
        end
      end
      format.html { render action: "new"}
      format.json { render json: @job.errors, status: :unprocessable_entity }
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:id])

    respond_to do |format|
      if !owner?(@job)
        flash[:error] = "Dazu hast du keine Berechtigung!"
      elsif @job.update_attributes(params[:job])
        ConflictHelper.delete_management(@device, @job.id-1)
        flash[:success] = "Auftrag wurde erfolgreich geaendert"
        format.html { redirect_to root_path }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:id])
    
    if !owner?(@job)
      flash[:error] = "Dazu hast du keine Berechtigung!"
    elsif ConflictHelper.is_processing?(@job)
      flash[:error] = "Auftrag wird gerade bearbeitet und kann nicht mehr geloescht werden"
    else
      job_id = @job.id
      @job.destroy
      if @device.jobs.find(:all, :conditions => ["finished == ?", 0]).count == 0
        @device.update_attributes(:state => 0)
      else
        ConflictHelper.delete_management(@device, job_id)
      end
      flash[:success] = "Auftrag wurde erfolgreich geloescht"
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
      format.js { render :nothing => true, :status => 200 }
    end
  end

end
