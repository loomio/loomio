module Oauth2Helper

  def has_facebook?
    Rails.application.secrets.facebook_key and Rails.application.secrets.facebook_secret
  end

  def has_twitter?
    Rails.application.secrets.twitter_key and Rails.application.secrets.twitter_secret
  end

  def has_google?
    Rails.application.secrets.google_key and Rails.application.secrets.google_secret
  end

  def has_persona?
    !Rails.application.secrets.disable_persona
  end

  def has_custom_oauth2?
    Rails.application.secrets.custom_oauth2_key and Rails.application.secrets.custom_oauth2_secret
  end

  def has_email_password?
    !Rails.application.secrets.disable_email_password
  end

end
