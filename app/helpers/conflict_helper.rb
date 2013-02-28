module ConflictHelper

  def self.delete_management(device, job_id)
     #Zwischenspeichern der nachfolgenden Jobs
     jobs = device.jobs.order("id ASC").find(:all, :conditions => ["finished == ? and id > ?", 0, job_id])
     #Loeschen der nachfolgenden Jobs
     Job.delete_all([ "finished = ? AND id > ? AND device_id = ?", 0,job_id,device.id ])
     jobs.each do |j| 
       if device.jobs.find(:all, :conditions => ["finished == ?", 0]).count == 0
         device.update_attributes(:state => 0)
         management_for_first_job(j)
         if j.start.to_datetime <= DateTime.now
           UserMailer.confirm_possible( User.find(j.user_id), 
                                        Device.find(j.device_id),
                                        Program.find(j.program_id),
                                        j).deliver
         end
       else
         management_if_more_jobs(j)
       end
       updated_job = j.dup
       updated_job.update_attributes(:id => j.id)
       updated_job.save
     end
   end

   def self.conflict_management(job, device)
     if device.state == 0
       management_for_first_job(job)
       return false
     else
       return management_if_more_jobs(job)
     end
   end

   def self.management_if_more_jobs(job)
     device = Device.find(job.device_id)
     duration = get_duration(job)
     best_time_to_start = DateTime.now.change({ :hour => Setting.find(1).sun_hour.to_i,
                                                 :min => Setting.find(1).sun_minute.to_i,
                                                 :sec => Setting.find(1).sun_second.to_i})
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

   def self.management_for_first_job(job)
     device = Device.find(job.device_id)
     duration = get_duration(job)
     best_time_to_start = DateTime.now.change({ :hour => Setting.find(1).sun_hour.to_i,
                                                 :min => Setting.find(1).sun_minute.to_i,
                                                 :sec => Setting.find(1).sun_second.to_i})
     current_time = DateTime.now

     if best_time_to_start >= job.end_of_timespan || best_time_to_start <= current_time
       job.start = current_time # Weit vor 12 oder Weit nach 12
       if job.confirm
         job.update_attributes(:is_running => true)
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



   #def self.is_next_job(job_to_tested, device_id)
  #   if job_to_tested.finished == 0 && Device.find(device_id).jobs.find_all{ |j| j.finished == 0 }.count == 1
   #    true
    # else
     #  false
    # end
   #end

   #Gibt die Gesamtdauer aller wartender Jobs zurueck
   def self.duration_of_queue(device_id)
     dur = 0
     Device.find(device_id).jobs.find(:all, :conditions => ["finished == ?", 0]).each { |j| 
       dur += get_duration(j) unless is_processing?(j)
     }

     dur
   end

   #Gibt den Gesamtabstand zwischen den Jobs zurueck
   def self.entire_space_between_jobs(device_id)
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
   def self.space_between(job_1,job_2)
     end_of_job_1 = job_1.start.to_datetime + get_duration(job_1).minute
     space = ((job_2.start.to_datetime - end_of_job_1.to_datetime).to_f*24*60).to_i

     space
   end

   # -2 => Job kann komplett ab 12 uhr starten
   # -1 => Job muss vor 12 Fertig sein
   def self.get_benefit_from_sun(job, duration, sun_time)
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

   def self.first_job(device_id)
     first_job = Device.find(device_id).jobs.order("id ASC").limit(1).find(:all, :conditions => ["finished == ?", 0])

     first_job[0]
   end

   def self.last_job(device_id)
     last_job = Device.find(device_id).jobs.order("id DESC").limit(1).find(:all, :conditions => ["finished == ?", 0])

     last_job[0]
   end
   def self.start_now(device_id, job)
     job.update_attributes(:start => DateTime.now)
     if job.confirm
       job.update_attributes(:is_running => true)
       Device.find(device_id).update_attributes(:state => 2)
       UserMailer.job_start( User.find(job.user_id), 
                                     Device.find(device_id),
                                     Program.find(job.program_id),
                                     job).deliver
     else
       UserMailer.confirm_possible( User.find(job.user_id), 
                                    Device.find(device_id),
                                    Program.find(job.program_id),
                                    job).deliver
     end
   end

   #"entire_space_to_shift" gibt an, wieviel verschoben werden soll
   # Wenn -1 oder -2 dann maximale Verschiebung
   def self.shift_jobs(device_id, entire_space_to_shift)
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

   def self.is_processing?(first_job)
     
     first_job.is_running && finished == 0
   end

   def self.get_duration(job)

     Program.find(job.program_id).duration_in_min
   end

   def self.possible_start_if_shifting(device_id)
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
