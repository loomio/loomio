class GroupMailer < BaseMailer
  def new_membership_request(membership_request)
    @membership_request = membership_request
    if @membership_request.requestor
      requestor_language_preference = @membership_request.requestor.language_preference
    end
    @group = membership_request.group
    @admins = @group.admins.map(&:email)
    set_email_locale(User.find_by_email(@group.admin_email).language_preference, requestor_language_preference)
    mail  :to => @admins,
          :reply_to => @group.admin_email,
          :subject => "#{email_subject_prefix(@group.full_name)} " + t("email.membership_request.subject", who: membership_request.name)
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
