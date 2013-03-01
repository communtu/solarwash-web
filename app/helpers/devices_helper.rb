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
      'class="icon-circle-blank icon_ready" rel="popover" title="Tipp" data-content="Dieses Gerät ist leer und bereit."'.html_safe
    elsif state == 1
      'class="icon-circle icon_waiting" rel="popover" title="Tipp" data-content="Dieses Gerät ist voll und wartet."'.html_safe
    else
      'class="icon-refresh icon_working" rel="popover" title="Tipp" data-content="Dieses Gerät arbeitet gerade."'.html_safe
    end
  end
  
  def type_icon(devicetype)
    if devicetype == 0
      'class="icon-tint icon-4x icon_devicetype" rel="popover" title="Tipp" data-content="Waschmaschine"'.html_safe
    elsif devicetype == 1
      'class="icon-fire icon-4x icon_devicetype" rel="popover" title="Tipp" data-content="Trockner"'.html_safe
    else
      'class="icon-ban-circle icon-4x icon_devicetype" rel="popover" title="Tipp" data-content="Unbekannter Gerätetyp"'.html_safe
    end
  end

  def vacant_device(type)
    Device.all.map { |d|
      if d.devicetype == type && d.state == 0 # Geraet laeuft nicht und ist leer       
        if type == 0
          return 'class="icon-ok icon_baseline brand white" rel="popover" data-placement="bottom" title="Glück gehabt" data-content="Es ist mindestens eine Waschmaschine frei"'.html_safe
        elsif type == 1
          return 'class="icon-ok icon_baseline brand white" rel="popover" data-placement="bottom" title="Glück gehabt" data-content="Es ist mindestens ein Trockner frei."'.html_safe
        end
      end      
    }

    if type == 0
      'class="icon-ban-circle icon_baseline white" rel="popover" data-placement="bottom" title="Sorry" data-content="Leider ist gerade keine Waschmaschine frei. Du kannst aber einen Auftrag einreihen."'.html_safe
    elsif type == 1
      'class="icon-ban-circle icon_baseline white" rel="popover" data-placement="bottom" title="Sorry" data-content="Leider ist gerade kein Trockner frei. Du kannst aber einen Auftrag einreihen."'.html_safe
    end
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