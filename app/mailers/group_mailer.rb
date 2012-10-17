class GroupMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_membership_request(membership)
    @user = membership.user
    @group = membership.group
    @admins = @group.admins.map(&:email)
    mail( :to => @admins,
          :reply_to => @group.admin_email,
          :subject => "#{email_subject_prefix(@group.full_name)} New membership" +
      " request from #{@user.name}")
  end

  def group_email(group, sender, subject, message, recipient)
    @group = group
    @sender = sender
    @message = message
    @recipient = recipient
    mail  :to => @recipient.email,
          :reply_to => @group.admin_email,
          :subject => "#{email_subject_prefix(@group.full_name)} #{subject}"
  end

  def deliver_group_email(group, sender, subject, message)
    group.users.each do |user|
      if user != sender && user.accepted_or_not_invited? && user.send_email?
        GroupMailer.group_email(group, sender, subject, message, user).deliver
      end
    end
  end

  def new_group_invited_to_loomio(admin_email, group_name)
    @group_name = group_name
    mail :to => admin_email,
         :from => "\"Loomio\" <contact@loom.io>",
         :subject => "Invitation to join Loomio (#{group_name})"
  end

  # def invite_to_group(recipient, invite)
  #   @invite = invite
  #   mail :to => recipient,
  #        :reply_to => invite.inviter_email,
  #        :subject => ("#{invite.inviter_name} has invited you to join " +
  #                     "#{invite.group_full_name} on Loomio")
  # end
end
