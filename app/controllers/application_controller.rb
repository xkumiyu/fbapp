class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  protect_from_forgery

  helper_method :current_user

  private
    def current_user
      if session[:user_id]
        user = User.find_by(session[:user_id])
        redirect_to signout_url if user.nil?
        @current_user ||= user
      end
    end

end
