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

  # Invited to loomio (assumes user has been invited to a group at the same time)
  def invited_to_loomio(new_user, inviter, group)
    @new_user = new_user
    @inviter = inviter
    @group = group
    mail(:to => new_user.email,
         :subject => "#{inviter.name} has invited you to #{group.name} on Loomio")
  end
end
