class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user

  def authenticate_user
    if session[:user_id]
      true
    else
      redirect_to '/login'
    end
  end

  def current_user
    User.find(session[:user_id])
  end
end
