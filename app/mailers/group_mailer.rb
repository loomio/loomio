class GroupMailer < ApplicationMailer
  def admin_deletion_warning(group_id, recipient_id, requestor_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    requestor = User.find(requestor_id)

    component = Views::GroupMailer::AdminDeletionWarning.new(
      group: group,
      recipient: recipient,
      requestor: requestor,
      usage: GroupUsageSummary.for(group)
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    }
  end

  def expired_trial_deletion_warning(group_id, recipient_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)

    component = Views::GroupMailer::ExpiredTrialDeletionWarning.new(
      group: group,
      recipient: recipient,
      usage: GroupUsageSummary.for(group)
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    }
  end
end
