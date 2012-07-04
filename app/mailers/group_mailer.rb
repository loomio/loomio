class GroupMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_membership_request(membership)
    @user = membership.user
    @group = membership.group
    @admins = @group.admins.map(&:email)
    mail(:to => @admins, :subject => "[Loomio: #{@group.full_name}] New membership" +
      " request from #{@user.name}")
  end
end
