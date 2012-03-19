class GroupMailer < ActionMailer::Base
  default :from => "noreply@loom.io"

  def new_membership_request(membership)
    @user = membership.user
    @group = membership.group
    @admins = @group.admins.map(&:email)
    mail(:to => @admins, :subject => "[Loomio: #{@group.name}] Membership waiting approval.")
  end
end
