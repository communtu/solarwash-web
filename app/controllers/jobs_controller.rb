class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.json
  def index
    @device = Device.find(params[:device_id])
    @job = @device.jobs.all

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

    @job.end_of_timespan = DateTime.strptime(params[:job]['end_of_timespan'], '%d.%m.%Y %H:%M')

    respond_to do |format|

      if @job.save
        format.html { redirect_to [@device, @job], notice: 'Auftrag wurde erfolgreich angelegt.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new"}
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    @device = Device.find(params[:device_id])
    @job = @device.jobs.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Auftrag wurde erfolgreich geändert.' }
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
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
  
  def no_conflict
    device = Device.find(@job.device_id)
    duration = Program.find(@job.program_id).duration_in_min
    best_time_to_start = DateTime.now.change({:hour => 12, :min => 0, :sec => 0})
    
    #TODO test_zeit mit DateTime.now austauschen!
    #test_zeit = DateTime.now.change({:hour => 8, :min => 0, :sec => 0})
    test_zeit = DateTime.now
    if device.state == 0
      #Kein Auftrag
      if best_time_to_start >= test_zeit && best_time_to_start <= @job.end_of_timespan
        #Auftrag kann vollstaendig ausgefuehrt werden, wenn er um 12:00Uhr beginnt
        @job.start = best_time_to_start
      elsif best_time_to_start >= test_zeit && best_time_to_start > @job.end_of_timespan
        #Auftrag kann nicht um 12:00Uhr beginnen, wird aber so gestartet, dass er noch
        #von der Sonne profitiert
        # evtl erstmal entfernen
        @job.start = @job.end_of_timespan - duration.minute
      else
        #Auftrag wird nach 12 Uhr gestartet
        @job.start = test_zeit
      end
      device.update_attributes(:state => 1)
    
    else
      last_job = device.jobs.last#
      last_program = Program.find(last_job.program_id)
      if last_job.start + last_program.duration_in_min.minute + duration.minute > @job.end_of_timespan
        #Auftrag kann nicht ausgefuehrt werden
        return false
      else
        #Auftrag kann ausgefuehrt werden
        if last_job.start + last_program.duration_in_min.minute > best_time_to_start
          #Job kann erst nach Sonne ausgefuehrt werden
          @job.start = last_job.start + last_program.duration_in_min.minute
        else
          #Sonne muss beruecksichtigt werden
          #TODO
          @job.start = last_job.start + last_program.duration_in_min.minute
        end
      end
    end
    
    true
  end
  
end
