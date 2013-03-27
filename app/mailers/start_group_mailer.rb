class StartGroupMailer < ActionMailer::Base
  default from: "\"Loomio\" <contact@loomio.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.group_invitation_mailer.invite_member.subject
  #

  def verification(group_request)
    @group_request = group_request
    @token = group_request.token

    mail to: group_request.admin_email,
         subject: "Please confirm your Loomio group request"
  end

  def invite_admin_to_start_group(group_request, message_body)
    @group_request = group_request
    @group = group_request.group
    @token = group_request.token
    @message_body = message_body

    mail to: group_request.admin_email,
         subject: "Invitation to join Loomio (#{@group.name})"
  end
end
