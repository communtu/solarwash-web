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
    job.is_running
  end
  
end
