class JobsController < ApplicationController
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
        if !conflict_management(@job)
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
    
    if is_processing?(@job)
      flash[:error] = "Auftrag wird gerade bearbeitet und kann nicht mehr geloescht werden"
    else
      job_id = @job.id
      @job.destroy
      if @device.jobs.count == 0
        @device.update_attributes(:state => 0)
      else
        delete_management(@device, job_id)
      end
      flash[:success] = "Auftrag wurde erfolgreich geloescht"
    end

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end
  
  def delete_management(device, job_id)
    #Zwischenspeichern der nachfolgenden Jobs
    jobs = device.jobs.order("id ASC").find(:all, :conditions => ["finished == ? and id > ?", 0, job_id])
    #Loeschen der nachfolgenden Jobs
    Job.delete_all([ "finished = ? AND id > ? AND device_id = ?", 0,job_id,device.id ])
    jobs.each do |j| 
      if device.jobs.count == 0
        device.update_attributes(:state => 0)
        management_for_first_job(j)
      else
        management_if_more_jobs(j)
      end
      updated_job = j.dup
      updated_job.update_attributes(:id => j.id)
      updated_job.save
    end
  end
  
  def conflict_management(job)
    if @device.state == 0
      management_for_first_job(job)
      return false
    else
      return management_if_more_jobs(job)
    end
  end
  
  def management_if_more_jobs(job)
    device = Device.find(job.device_id)
    duration = get_duration(job)
    best_time_to_start = DateTime.now.change({:hour => 12, :min => 0, :sec => 0})
    current_time = DateTime.now
    
    if possible_start_if_shifting(device.id).to_datetime + duration.minute >= job.end_of_timespan.to_datetime
      return true
    elsif current_time >= best_time_to_start + duration.minute
      #Sonne kann nicht beruecksichtigt werden => In Queue reihen
      job.start = last_job(device.id).start.to_datetime + get_duration(last_job(device.id)).minute
    else
      benefit_from_sun = get_benefit_from_sun(job, duration, best_time_to_start)
      if possible_start_if_shifting(device.id).to_datetime < best_time_to_start
        #< 12 -> Komplett shiften, start so, dass man am meisten von der Sonne profitiert
        shift_jobs(device.id, -1)
        job.start = (best_time_to_start + benefit_from_sun.minute) - duration.minute
      elsif possible_start_if_shifting(device.id).to_datetime > best_time_to_start + duration.minute
        # > 12 + duration -> Komplett shiften, start danach
        shift_jobs(device.id, -1)
        job.start = last_job(device.id).start.to_datetime + get_duration(last_job(device.id)).minute
      else
        # sonst: benefit_from_sun shiften, start danach
        shift_jobs(device.id, benefit_from_sun)
        job.start = last_job(device.id).start.to_datetime + get_duration(last_job(device.id)).minute
      end
    end
    return false
  end
  
  def management_for_first_job(job)
    device = Device.find(job.device_id)
    duration = get_duration(job)
    best_time_to_start = DateTime.now.change({:hour => 12, :min => 0, :sec => 0})
    current_time = DateTime.now
  
    if best_time_to_start >= job.end_of_timespan || best_time_to_start <= current_time
      job.start = current_time # Weit vor 12 oder Weit nach 12
      if job.confirm
        device.update_attributes(:state => 2)
      else
        device.update_attributes(:state => 1)
      end   
    else
      if best_time_to_start + duration.minute <= job.end_of_timespan
        job.start = best_time_to_start #12 Uhr starten
      else
        job.start = job.end_of_timespan - duration.minute
      end
      device.update_attributes(:state => 1)
    end
 end
    
  
  
  def is_next_job(job_to_tested, device_id)
    if job_to_tested.finished == 0 && Device.find(device_id).jobs.find_all{ |j| j.finished == 0 }.count == 1
      true
    else
      false
    end
  end
  
  #Gibt die Gesamtdauer aller wartender Jobs zurueck
  def duration_of_queue(device_id)
    dur = 0
    Device.find(device_id).jobs.find(:all, :conditions => ["finished == ?", 0]).each { |j| 
      dur += get_duration(j) unless is_processing?(j)
    }

    dur
  end
  
  #Gibt den Gesamtabstand zwischen den Jobs zurueck
  def entire_space_between_jobs(device_id)
    entire_space = 0
    jobs = Device.find(device_id).jobs.order("id ASC").find(:all, :conditions => ["finished == ?", 0])
    jobs.each_with_index { |j,index|
      if jobs[index+1] != nil
        entire_space += space_between(j, jobs[index+1])
      end
    }
    
    entire_space
  end
  
  #Gibt den Abstand zwischen zwei Jobs zurueck
  def space_between(job_1,job_2)
    end_of_job_1 = job_1.start.to_datetime + get_duration(job_1).minute
    space = ((job_2.start.to_datetime - end_of_job_1.to_datetime).to_f*24*60).to_i
    
    space
  end
  
  # -2 => Job kann komplett ab 12 uhr starten
  # -1 => Job muss vor 12 Fertig sein
  def get_benefit_from_sun(job, duration, sun_time)
    benefit = nil
    if job.end_of_timespan.to_datetime >=  sun_time.to_datetime + duration.minute
      benefit = duration
    elsif job.end_of_timespan.to_datetime < sun_time.to_datetime
      benefit = -1
    else
      benefit = ((job.end_of_timespan.to_datetime - sun_time.to_datetime).to_f*24*60).to_i
    end
    
    benefit
  end
  
  def first_job(device_id)
    first_job = Device.find(device_id).jobs.order("id ASC").limit(1).find(:all, :conditions => ["finished == ?", 0])
  
    first_job[0]
  end
  
  def last_job(device_id)
    last_job = Device.find(device_id).jobs.order("id DESC").limit(1).find(:all, :conditions => ["finished == ?", 0])

    last_job[0]
  end
  def start_now(device_id, job)
    job.update_attributes(:start => DateTime.now)
    if job.confirm
      Device.find(device_id).update_attributes(:state => 2)
    end
  end
  
  #"entire_space_to_shift" gibt an, wieviel verschoben werden soll
  # Wenn -1 oder -2 dann maximale Verschiebung
  def shift_jobs(device_id, entire_space_to_shift)
    jobs = Device.find(device_id).jobs.order("id ASC").find(:all, :conditions => ["finished == ?", 0])
    jobs.each_with_index do |j,index| 
      if !is_processing?(j) && jobs.count == 1
        #Sonderfall, falls nur 1 job
        start_now(device_id, j)
      elsif jobs[index +1] != nil
        current_space = space_between(j, jobs[index+1])
        #Beruecksichtigung von maximaler Verschiebung
        if !(entire_space_to_shift == -1) && !(entire_space_to_shift == -2)
          if current_space >= entire_space_to_shift
            current_space = entire_space_to_shift
            entire_space_to_shift = 0
          else
            entire_space_to_shift -= current_space
          end
        end
        
        #Verschiebung der benachbarten Jobs
        if current_space > 0
          new_start = jobs[index+1].start.to_datetime - current_space.minute
          if new_start.to_datetime <= DateTime.now
            start_now(device_id, jobs[index+1])
          else
            jobs[index+1].update_attributes(:start => new_start.to_datetime)
          end
        end
      end
    end
  end
  
  def is_processing?(first_job)
    if DateTime.now <= first_job.start.to_datetime
      false
    else
      true
    end
  end
  
  def get_duration(job)
    
    Program.find(job.program_id).duration_in_min
  end
  
  def possible_start_if_shifting(device_id)
    first_job = first_job(device_id) 
    if is_processing?(first_job)
      return  first_job.start.to_datetime +
              get_duration(first_job).minute +
              duration_of_queue(device_id).minute
    else
      #Erster Job muesste sofort starten
      return DateTime.now + duration_of_queue(device_id).minute
    end
  end
  
  
end
