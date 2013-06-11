class StartGroupMailer < ActionMailer::Base
  default from: "\"Loomio\" <contact@loomio.org>", :css => :email

  def verification(group_request)
    @group_request = group_request
    @token = group_request.token

    mail to: group_request.admin_email,
         subject: t('verified_email.subject')
  end

  def defered(group_request)
    @group_request = group_request

    mail to: group_request.admin_email,
         subject: t('defered_email.subject')
  end
end
