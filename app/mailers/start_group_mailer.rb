class StartGroupMailer < ActionMailer::Base
  default from: "\"Loomio\" <contact@loomio.org>", :css => :email

  def verification(group_request)
    @group_request = group_request
    @token = group_request.token

    mail to: group_request.admin_email,
         subject: "Thanks for your request, you're almost done!"
  end

  def defered(group_request)
    @group_request = group_request

    mail to: group_request.admin_email,
         subject: "defered (placeholder)"
  end
end
