class UserMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def group_membership_approved(user, group)
    @user = user
    @group = group
    mail( :to => user.email, 
          :reply_to => @group.admin_email,
          :subject => "[Loomio: #{group.full_name}] Membership approved")
  end

  def added_to_group(user, group)
    @user = user
    @group = group
    mail( :to => user.email,
          :reply_to => @group.admin_email,
          :subject => "[Loomio] You've been added to a group called '#{@group.full_name}'")
  end

  # Invited to loomio (assumes user has been invited to a group at the same time)
  def invited_to_loomio(new_user, inviter, group)
    @new_user = new_user
    @inviter = inviter
    @group = group
    mail( :to => new_user.email,
          :reply_to => @group.admin_email,
          :subject => "#{inviter.name} has invited you to #{group.full_name} on Loomio")
  end
end
