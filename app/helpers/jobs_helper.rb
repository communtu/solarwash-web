module JobsHelper
  def setDefaultConfirm(state)
    if state == 0
      "true"
    else
      "false"
    end
  end
end
