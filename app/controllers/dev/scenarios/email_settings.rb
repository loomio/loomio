module Dev::Scenarios::EmailSettings
  def email_settings_as_logged_in_user
    create_group
    sign_in patrick
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end

  def email_settings_as_restricted_user
    create_group
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end
end
