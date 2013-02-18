class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email].downcase)
    if @user
      session[:user] = @user
      redirect_to root_path
    else
      flash.now[:error] = 'Invalid email/password combination'    
      render 'new'
    end
  end

  def destroy
    if session[:user]
      session.delete(:user)
      redirect_to root_path
    end
  end
end
