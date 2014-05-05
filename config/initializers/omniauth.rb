Rails.application.config.middleware.use OmniAuth::Builder do

  provider :facebook,
    Settings.OmniAuth.facebook.app_id,
    Settings.OmniAuth.facebook.app_secret,
    display: 'popup',
    scope: 'user_likes,friends_likes'

end
