class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'csv'

  helper_method :current_user

  protected 
  def authenticate_user
    if session[:user_id]
       # set current user object to @current_user object variable
      @current_user = current_user
      return true 
    else
      redirect_to(:controller => 'users', :action => 'login')
      return false
    end
  end

  def authenticate_admin_user
    if session[:user_id]
       # set current user object to @current_user object variable
      if current_user.username == 'admin' && session[:user_id] == 1
        return true 
      end
    end

    redirect_to(:controller => 'portal', :action => 'sessionconnectioninfos')
    return false
  end

  private

  def current_user
    @current_user ||= UserAuthentication.find(session[:user_id]) if session[:user_id]
  end
end
