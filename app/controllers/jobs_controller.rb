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
    
    @job.end_of_timespan = DateTime.strptime(params[:job]['end_of_timespan'], '%d.%m.%Y %H:%M') - 1.hour

    #if conflict
    #   format.html { render action: "new"}
    #   format.json { render json: @job.errors, status: :unprocessable_entity }
    #end

    


    respond_to do |format|
      if @job.save
        format.html { redirect_to root_path, notice: 'Auftrag wurde erfolgreich angelegt.' }
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
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
  
  # TODO DRY & refactoring machen! :)
  def conflict
    device = Device.find(@job.device_id)
    duration = Program.find(@job.program_id).duration_in_min
    best_time_to_start = DateTime.now.change({:hour => 12, :min => 0, :sec => 0})
    
    #aktuelle_zeit = DateTime.now.change({:hour => 8, :min => 0, :sec => 0})
    aktuelle_zeit = DateTime.now
    
    if device.state == 0
      #Kein Auftrag
      if best_time_to_start >= aktuelle_zeit
        #Es ist vor 12 Uhr, Sonne muss beruecksichtigt werden
        if best_time_to_start >= @job.end_of_timespan
          #Auftrag soll vor Sonnenzeit fertig sein => Auftrag wird sofort gestartet
          @job.start = aktuelle_zeit
          
        elsif best_time_to_start + duration.minute <= @job.end_of_timespan
          #Auftrag kann vollstaendig ausgefuehrt werden, wenn er um 12:00Uhr beginnt
          @job.start = best_time_to_start
        else
          #Auftrag kann nicht um 12:00Uhr beginnen, kann aber teilweise von der Sonne profitieren
          @job.start = @job.end_of_timespan - duration.minute
        end
      else
        #Es ist nach 12 Uhr, Auftrag wird jetzt gestartet
        @job.start = aktuelle_zeit
        if @job.confirm
          #Waschmaschine wird angeschaltet
          device.update_attributes(:state => 2)
        end
      end
      #Waschmaschine wartet auf Startzeitpunkt
      device.update_attributes(:state => 1) unless @job.confirm
    
    else
      #Es gibt Auftraege
      last_job = device.jobs.last
      last_program = Program.find(last_job.program_id)
      
      if last_job.start + last_program.duration_in_min.minute + duration.minute > @job.end_of_timespan
        #Auftrag kann nicht ausgefuehrt werden
        return true
      else
        #Auftrag kann ausgefuehrt werden
        if last_job.start > best_time_to_start || aktuelle_zeit > best_time_to_start
          #Sonne spielt keine Rolle => Auftrag wird nach dem vorherigen ausgefuehrt
          @job.start = last_job.start + last_program.duration_in_min.minute
        else
          #Sonne spielt eine Rolle
          if last_job.start + last_program.duration_in_min.minute < best_time_to_start
            #vorheriger Auftrag ist vor der Sonnenzeit beendet 
            if best_time_to_start + duration.minute <= @job.end_of_timespan  
              #Auftrag kann vollstaendig ausgefuehrt werden, wenn er um 12:00Uhr beginnt
              @job.start = best_time_to_start
            else
              #Auftrag kann nicht um 12:00Uhr beginnen, kann aber teilweise von der Sonne profitieren
              @job.start = @job.end_of_timespan - duration.minute
            end
          
          else
            #vorheriger Auftrag ist innerhalb der Sonnenzeit
            if is_next_job(job_to_tested, device_id)
              #Waschmaschine ist frei und der vorherige wird als nächstes bearbeitet          
              if aktuelle_zeit < best_time_to_start - last_program.duration_in_min.minute &&
                 best_time_to_start + duration <= @job.end_of_timespan
                #vorheriger Auftrag kann verschoben werden
                job.update_attributes(:start => aktuelle_zeit)
                #Waschmaschine wird gestartet
                device.update_attributes(:state => 2)
                #Neuer Auftrag beginnt zur Sonnenzeit
                @job.start = best_time_to_start
                false
              end
            end
          #Verschiebung nicht moeglich
          @job.start = last_job.start + last_program.duration_in_min.minute
          end
        end
      end
    end
    #Keine Konflikte
    false
  end
  
  def is_next_job(job_to_tested, device_id)
    if job_to_tested.finished == 0 && Device.find(1).jobs.find_all{ |j| j.finished == 0 }.count == 1
      true
    else
      false
    end
  end
end
