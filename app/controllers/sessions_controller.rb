class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    if user.token != auth['credentials']['token']
      user.token = auth['credentials']['token']
      user.save
    end

    session[:user_id] = user.id

    if session[:status] == "update"
      redirect_to '/users/renew'
      session[:status] = nil
    else
      redirect_to users_url
    end
  end


  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
