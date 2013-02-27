class ApplicationController < ActionController::Base
 
  before_filter :authenticate_user!

  #def authenticate_admin_user!
  #  redirect_to new_user_session_path unless current_user.try(:is_admin?) 
  #end


  def authenticate_admin_user!
    authenticate_user! 
    unless current_user.admin?
      flash[:error] = "This area is restricted to administrators only."
      redirect_to root_path 
    end
  end

  def current_admin_user
    return nil if user_signed_in? && !current_user.admin?
    current_user
  end
  protect_from_forgery

  helper_method :development_mode?

  protected

  def development_mode?
    Rails.env.development?
  end

end