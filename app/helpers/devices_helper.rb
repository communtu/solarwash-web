# encoding: utf-8

module DevicesHelper
  def type_title(devicetype)
    if devicetype == 0
      "Waschmaschine"
    elsif devicetype == 1
      "Trockner"
    else
      "Unbekannter Gerätetyp"
    end
  end

  def clothes_inside(devicetype)
    if devicetype == 0
      "Wäsche in der Waschmaschine?"
    elsif devicetype == 1
      "Wäsche im Trockner?"
    else
      "Wäsche im unbekannten Gerät?"
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
    if job.is_running
       entire_duration = Program.find(job.program_id).duration_in_min
  		 balance_time = entire_duration -  ((DateTime.now - job.start.to_datetime).to_f*24*60).to_i
  		 percent = ((entire_duration-balance_time).to_f/entire_duration.to_f*100).to_i
  		  
       "<div class='progress progress-striped active'>
            <div class='bar' style= 'width: #{percent}%;'></div>
       </div>".html_safe
  	else
  	    "<p style='text-align:center'> - </p>".html_safe
	  end
  end
  
end