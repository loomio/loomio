class StartGroupMailer < ActionMailer::Base
  default from: "\"Loomio\" <contact@loomio.org>", :css => :email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.group_invitation_mailer.invite_member.subject
  #

  def invite_admin_to_start_group(group_request)
    @group_request = group_request
    @group = group_request.group
    @token = group_request.token

    mail to: group_request.admin_email,
         subject: "Invitation to join Loomio (#{@group.name})"
  end
end
