class GroupInvitationMailer < ActionMailer::Base
  default from: "contact@loom.io"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.group_invitation_mailer.invite_member.subject
  #
  def invite_member(args)
    invite(args)
  end

  def invite_admin(args)
    args[:inviter] ||= User.loomio_helper_bot
    invite(args)
  end

  private

  def invite(args)
    @group = args[:group]
    @token = args[:token]
    @inviter = args[:inviter]

    mail to: args[:recipient_email],
         reply_to: @inviter.email,
         subject: "Invitation to join Loomio (#{@group.name})"
  end

end
