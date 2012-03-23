class UserMailer < ActionMailer::Base
  default :from => "noreply@loom.io"

  def group_membership_approved(user, group)
    @user = user
    @group = group
    mail(:to => user.email, :subject => "[Loomio: #{group.name}] Membership approved")
  end

  def added_to_group(user, group)
    @user = user
    @group = group
    mail(:to => user.email,
         :subject => "[Loomio] You've been added to a group called '#{@group.name}'")
  end
end
