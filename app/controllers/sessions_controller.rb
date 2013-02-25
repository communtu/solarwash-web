# encoding: utf-8

class SessionsController < ApplicationController

  before_filter :check_development_mode!

  def create
    Timecop.travel(params[:simulate_datetime])
    flash[:success] = "Zeit gesetzt auf #{params[:simulate_datetime]}."

    user_id = params[:user_id]

    if user = User.where(id: user_id).first
      sign_in(:user, user)
      flash[:success] = "Angemeldet als #{user.email}."
      redirect_to :root
    else
      flash[:error] = "Ungültige Benutzer-ID (#{user_id})."
      redirect_to :back
    end
  end

  protected

  def check_development_mode!
    unless development_mode?
      flash[:error] = "Nicht im Development Mode."
      redirect_to :back
    end
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

end