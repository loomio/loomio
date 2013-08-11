class GroupMailer < BaseMailer
  def new_membership_request(membership_request)
    @membership_request = membership_request
    @group = membership_request.group
    @group.admins.each do |admin|
      GroupMailer.delay.membership_request(admin, @membership_request)
    end
  end

  def membership_request(admin, membership_request)
    @membership_request = membership_request
    @group = membership_request.group
    locale = best_locale(admin.language_preference, nil)
    I18n.with_locale(locale) do
      mail  :to => admin.email,
            :reply_to => "#{@membership_request.name} <#{@membership_request.email}>",
            :subject => "#{email_subject_prefix(@group.full_name)} " + t("email.membership_request.subject", who: @membership_request.name)
    end
  end

  def group_email(group, sender, subject, message, recipient)
    @group = group
    @sender = sender
    @message = message
    @recipient = recipient
    locale = best_locale(recipient.language_preference, sender.language_preference)
    I18n.with_locale(locale) do
      mail  :to => @recipient.email,
            :reply_to => "#{sender.name} <#{sender.email}>",
            :subject => "#{email_subject_prefix(@group.full_name)} #{subject}"
    end
  end

  def deliver_group_email(group, sender, subject, message)
    group.users.each do |user|
      unless user == sender
        GroupMailer.delay.group_email(group, sender, subject, message, user)
      end
    end
  end
end
