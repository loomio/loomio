class GroupMailer < BaseMailer
  def self.new_membership_request(membership_request)
    @membership_request = membership_request
    @group = membership_request.group
    @group.admins.each do |admin|
      GroupMailer.membership_request(admin, @membership_request).deliver_later
    end
  end

  def membership_request(admin, membership_request)
    @membership_request = membership_request
    @group = membership_request.group
    locale = locale_fallback(admin.locale)
    I18n.with_locale(locale) do
      mail  to: admin.name_and_email,
            reply_to: "#{@membership_request.name} <#{@membership_request.email}>",
            subject: t("email.membership_request.subject", who: @membership_request.name, which_group: @group.full_name)
    end
  end

  def group_email(group, sender, subject, message, recipient)
    @group = group
    @sender = sender
    @message = message
    @recipient = recipient
    locale = locale_fallback(recipient.locale, sender.locale)
    I18n.with_locale(locale) do
      mail  to: @recipient.email,
            reply_to: sender.name_and_email,
            subject: "#{email_subject_prefix(@group.full_name)} #{subject}"
    end
  end

  def self.deliver_group_email(group, sender, subject, message)
    group.users.each do |user|
      unless user == sender
        GroupMailer.group_email(group, sender, subject, message, user).deliver_later
      end
    end
  end
end
