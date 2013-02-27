class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  protect_from_forgery

  helper_method :development_mode?

  protected

  def development_mode?
    Rails.env.development?
  end

end