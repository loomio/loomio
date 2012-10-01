class GroupInvitationMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.group_invitation_mailer.invite_member.subject
  #
  def invite_member
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
