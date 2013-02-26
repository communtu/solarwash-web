class JobsController < ApplicationController
  include ConflictHelper
  
  # GET /jobs
  # GET /jobs.json
  def index    
    @jobs = Job.all.find_all{ |job| job.user_id == 1 } # TODO tatsaechlichen User nehmen

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
      if @job.update_attribute('confirm',true)
        if @job.start.to_datetime < DateTime.now
          @job.update_attribute('start', DateTime.now)
        end
        
          format.html { redirect_to root_path, notice: 'Vorgang wird so frueh wie moeglich gestartet!' }
          format.json { head :no_content }
      else
          format.html { redirect_to root_path, notice: 'Fehler bei dem Update' }
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
    
    confirm = 0  if @job.confirm == nil

    if !@job.end_of_timespan.is_a?(ActiveSupport::TimeWithZone)
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
          flash[:error] = "Aufgrund von anderen Auftraegen, kann die Waesche nicht rechtzeitig fertig werden"
        end
      else
        flash[:error] = "Der Vorgang dauert mindestens #{Program.find(@job.program_id).duration_in_min} Minuten!"
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
      if @job.update_attributes(params[:job])
        format.html { redirect_to root_path, notice: 'Auftrag wurde erfolgreich geaendert.' }
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
    
    if ConflictHelper.is_processing?(@job)
      flash[:error] = "Auftrag wird gerade bearbeitet und kann nicht mehr geloescht werden"
    else
      job_id = @job.id
      @job.destroy
      if @device.jobs.count == 0
        @device.update_attributes(:state => 0)
      else
        ConflictHelper.delete_management(@device, job_id)
      end
      flash[:success] = "Auftrag wurde erfolgreich geloescht"
    end

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

end
