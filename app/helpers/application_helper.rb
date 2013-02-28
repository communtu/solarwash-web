module ApplicationHelper	
  def owner?(job)
    if current_admin_user
      true
    else
      job.user_id == current_user.id
    end
  end

   def current_admin_user
    return nil if user_signed_in? && !current_user.admin?
    current_user
  end
end
