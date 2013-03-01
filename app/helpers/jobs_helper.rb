module JobsHelper
  def setDefaultConfirm(state)
    if state == 0
      "true"
    else
      "false"
    end
  end
  
  def has_to_be_confirmed(device, job)
    first_job = device.jobs.order("id ASC").limit(1).find(:all, :conditions => ["finished == ?", 0])
    if first_job[0] == job && job.confirm != true
      return true
    else
      return false
    end
  end

  def is_running?(job)
    
    job.is_running && job.finished == 0
  end
  
  def self.errormsg_end_of_timespan(device_id, job)
    if Device.find(device_id).jobs.find(:all, :conditions => ["finished == ?", 0]).count == 0
      duration = ConflictHelper.get_duration(job)
      earliest_start_time = DateTime.now + duration.minute
    else
      endtime_of_last_job = ConflictHelper.possible_start_if_shifting(device_id)
      duration = ConflictHelper.get_duration(job)
      earliest_start_time = endtime_of_last_job.to_datetime + duration.minute
    end
    
    "Deine Waesche kann fruehestens um #{earliest_start_time.to_time.strftime('%H:%M')}Uhr fertig werden!"
  end
end
