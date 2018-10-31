class OnboardingMailer < UserMailer
  layout 'invite_people_mailer'
  def welcome(user)
    @user = user
    send_single_mail to:            @user.email,
                     locale:        @user.locale,
                     from:          ENV['WELCOME_EMAIL_SENDER_EMAIL'],
                     reply_to:      ENV['SUPPORT_EMAIL'],
                     subject_key:   "onboarding_mailer.welcome.subject"
  end
end
