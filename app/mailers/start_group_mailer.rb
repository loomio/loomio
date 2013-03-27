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

  def invite_admin_to_start_group(invitation, message_body)
    puts invitation.inspect
    @invitation = invitation
    @group = invitation.group
    @token = invitation.token
    @message_body = message_body

    mail to: invitation.recipient_email,
         subject: "Invitation to start Loomio group #{@group.name}"
  end
end
