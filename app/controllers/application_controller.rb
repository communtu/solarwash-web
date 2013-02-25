class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :development_mode?

  protected

  def development_mode?
    Rails.env.development?
  end

end