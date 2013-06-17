class GroupMailer < BaseMailer
  def new_membership_request(membership)
    @user = membership.user
    @group = membership.group
    @admins = @group.admins.map(&:email)
    set_email_locale(User.find_by_email(@group.admin_email).language_preference, @user.language_preference)
    mail  :to => @admins,
          :reply_to => @group.admin_email,
          :subject => "#{email_subject_prefix(@group.full_name)} " + t("email.membership_request.subject", who: @user.name)
  end

  def group_email(group, sender, subject, message, recipient)
    @group = group
    @sender = sender
    @message = message
    @recipient = recipient
    set_email_locale(recipient.language_preference, sender.language_preference)
    mail  :to => @recipient.email,
          :reply_to => "#{sender.name} <#{sender.email}>",
          :subject => "#{email_subject_prefix(@group.full_name)} #{subject}"
  end

  def deliver_group_email(group, sender, subject, message)
    group.users.each do |user|
      unless user == sender
        GroupMailer.group_email(group, sender, subject, message, user).deliver
      end
    end
  end
end
