Rails.application.config.middleware.use OmniAuth::Builder do

  provider :facebook,
    '179079062221946',
    '9eb1243e8ea1fbca93019b4e27d34f48',
    # Settings.OmniAuth.facebook.app_id,
    # Settings.OmniAuth.facebook.app_secret,
    display: 'popup'

end
