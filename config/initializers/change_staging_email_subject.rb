if Rails.env.staging?
  class ChangeStagingEmailSubject
    def self.delivering_email(mail)
      mail.subject = "[TEST] " + mail.subject
    end
  end
  ActionMailer::Base.register_interceptor(ChangeStagingEmailSubject)
end
