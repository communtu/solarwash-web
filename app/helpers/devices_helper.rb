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

end