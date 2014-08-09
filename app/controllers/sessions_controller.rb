class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]

    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    if user.nil?
      user = User.create_with_omniauth(auth)
      session[:status] = 'first'
    end
    session[:user_id] = user.id

    if user.token != auth['credentials']['token']
      user.token = auth['credentials']['token']
      user.save
    end

    redirect_to users_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
