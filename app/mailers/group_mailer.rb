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
      unless user == sender || !user.accepting_or_not_invited?
        GroupMailer.group_email(group, sender, subject, message, user).deliver
      end
    end
  end
  
end
