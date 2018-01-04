class UsersController < ApplicationController
  before_filter :authenticate_admin_user, :only => [:new, :create, :admin_password_change, :admin_update_password]

  def index
    redirect_to(controller: "portal", action: "sessionconnectioninfos")
  end

  def new
    flash[:error] = nil
    @user = UserAuthentication.new 
  end

  def create
    @user = UserAuthentication.new(user_params)
    if @user.save
      flash[:error] = nil
      redirect_to portal_sessionconnectioninfos_path
      return
    else
      flash[:error] = "Invalid Form: "
      flash[:color]= "invalid"
    end

    redirect_to :action => "new"
  end

  def admin_password_change

  end

  def admin_update_password 
    if (params.has_key?(:password) && params[:password] != '' && params.has_key?(:username))    
      @usr_toupdate = UserAuthentication.find_by(username: params[:username])
      if @usr_toupdate 
        @usr_toupdate.password = params[:password]
        @usr_toupdate.password_confirmation = params[:password_confirmation]
        @usr_toupdate.encrypt_password
        if @usr_toupdate.save()
          flash[:success] = 'Password updated successfully'
          flash[:error] = nil
        else
          flash[:error] = "Invalid Form: "
        end
      else
        flash[:error] = "Username is not found"
      end
    else
      flash[:error] = "Username or Password is required"
    end

    redirect_to :action => "admin_password_change"
  end

  def login
  end

  def login_authenticate
    user = UserAuthentication.authenticate(params[:username], params[:password])
    if user
      session[:user_id] = user.id
      session[:user_tz] = user.timezone
      redirect_to portal_experimentlist_path, :notice => "Logged in!"
    else
      flash.now[:error] = "Invalid username or password"
      render "login"
    end
  end

  def logout
    session[:user_id] = nil
    session[:user_tz] = nil
    puts 'redirecting'
    flash[:error] = nil
    redirect_to :action => "login"
  end

  private 

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
