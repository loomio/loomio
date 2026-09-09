class GroupMailer < ApplicationMailer
  def destroy_warning(group_id, recipient_id, requestor_id = nil, reason = nil)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    requestor = User.find(requestor_id) if requestor_id

    component = Views::GroupMailer::DestroyWarning.new(
      group: group,
      recipient: recipient,
      requestor: requestor,
      reason: reason,
      usage: GroupUsageSummary.for(group)
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    }
  end

  def trial_expired(group_id, recipient_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)

    component = Views::GroupMailer::TrialExpired.new(
      group: group, recipient: recipient
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.trial_expired.subject")
    }
  end
end
