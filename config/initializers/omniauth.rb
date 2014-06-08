Rails.application.config.middleware.use OmniAuth::Builder do

  provider :facebook,
    Settings.OmniAuth.facebook.app_id,
    Settings.OmniAuth.facebook.app_secret,
    display: 'popup',
    scope: 'user_likes,user_birthday,friends_likes,friends_birthday'

end
