class GroupMailer < ApplicationMailer
  def admin_deletion_warning(group_id, recipient_id, requestor_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    requestor = User.find(requestor_id)

    component = Views::GroupMailer::AdminDeletionWarning.new(
      group: group,
      requestor: requestor,
      usage: GroupUsageSummary.for(group)
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    }
  end

  def expired_trial_deletion_warning(group_id, recipient_id, catch_up: false)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)

    component = Views::GroupMailer::ExpiredTrialDeletionWarning.new(
      group: group,
      usage: GroupUsageSummary.for(group),
      catch_up: catch_up
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    }
  end

  def canceled_subscription_deletion_warning(group_id, recipient_id, discarded_at)
    group = Group.discarded.find_by(id: group_id, discarded_at: discarded_at)
    recipient = group&.admins&.find_by(id: recipient_id)
    return unless recipient

    component = Views::GroupMailer::CanceledSubscriptionDeletionWarning.new(group: group, usage: GroupUsageSummary.for(group))

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) do
      I18n.t("group_mailer.destroy_warning_with_usage.subject")
    end
  end
end
