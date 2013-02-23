module DevicesHelper
  def type_title(devicetype)
    if devicetype == 0
      "Waschmaschine"
    else
      "Trockner"
    end
  end
  
  def state_image(state)
    if state == 0
      "icon-circle-blank icon_ready"
    elsif state == 1
      "icon-circle icon_waiting"
    else
      "icon-refresh icon_working"
    end
  end
  
  def type_icon(devicetype)
    if devicetype == 0
      "icon-tint"
    else
      "icon-fire"
    end
  end

  def vacant_device
    Device.all.map { |d|
      if d.state == 0 || d.state == 1 # Geraet laeuft nicht
        return "icon-ok"
      end      
    }
    "icon-ban-circle"
  end

  def format_start_time(job)
    if job.start < DateTime.now
       entire_duration = Program.find(job.program_id).duration_in_min
  		 balance_time = entire_duration -  ((DateTime.now - job.start.to_datetime).to_f*24*60).to_i
  		 percent = 100 - (100/entire_duration * balance_time)
  		 "Seit #{balance_time} min (#{percent}%) in Bearbeitung"		 
  	else
  	    job.start
	  end
  end
  
end