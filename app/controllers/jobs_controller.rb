class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(params[:job])

    respond_to do |format|
      if no_conflict && @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
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
    @job = Job.find(params[:id])
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
    test_zeit = DateTime.now.change({:hour => 08, :min => 0, :sec => 0})
    
    if device.state == 0
      #Kein Auftrag
      if best_time_to_start >= test_zeit && best_time_to_start <= @job.end_of_timespan
        #Auftrag kann vollstaendig ausgefuehrt werden, wenn er um 12:00Uhr beginnt
        @job.start = best_time_to_start
      elsif best_time_to_start >= test_zeit && best_time_to_start > @job.end_of_timespan
        #Auftrag kann nicht um 12:00Uhr beginnen, wird aber so gestartet, dass er noch
        #von der Sonne profitiert
        @job.start = @job.end_of_timespan - duration.min
      else
        #Auftrag wird nach 12 Uhr gestartet
        @job.start = test_zeit
      end
      device.update_attributes(:state => 1)
    
    else
      last_job = Device.find(@job.device_id).programs.last
      if last_job.start + last_job.duration_in_min.min + duration.min > @job.end_of_timespan
        #Auftrag kann nicht ausgefuehrt werden
        false
      else
        #Auftrag kann ausgefuehrt werden
        if(last_job.start + last_job.duration_in_min.min > best_time_to_start)
          #Job kann erst nach Sonne ausgefuehrt werden
          @job.start = last_job.start + last_job.duration_in_min.min
        else
          #Sonne muss beruecksichtigt werden
          @job.start = best_time_to_start
        end
      end
    end
    
    true
  end
  
end
