module ApplicationHelper	
  def owner?(job)
    return job.user_id == current_user.id
  end
end
