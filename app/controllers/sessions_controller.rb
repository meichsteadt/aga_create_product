class SessionsController < ApplicationController
  skip_before_action :authenticate_user
  def new

  end

  def create
    @user = User.find_by_email(params[:email]).authenticate(params[:password])
    if @user
      session[:user_id] = @user.id
      redirect_to '/'
    else
      flash[:error] = "That username and password wasn't correct"
      redirect_to new_session_path
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to '/'
  end
end
