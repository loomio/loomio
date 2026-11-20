class GroupMailer < ApplicationMailer
  def admin_deletion_warning(group_id, recipient_id, requestor_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    requestor = User.find(requestor_id)
    deletion_days = AppConfig.discarded_group_deletion_after_days

    component = Views::GroupMailer::AdminDeletionWarning.new(
      group: group,
      requestor: requestor,
      usage: GroupUsageSummary.for(group),
      deletion_days: deletion_days
    )

    send_group_notice(recipient, component, deletion_days)
  end

  def expired_trial_deletion_warning(group_id, recipient_id, catch_up: false)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    deletion_days = AppConfig.discarded_group_deletion_after_days

    component = Views::GroupMailer::ExpiredTrialDeletionWarning.new(
      group: group,
      usage: GroupUsageSummary.for(group),
      catch_up: catch_up,
      deletion_days: deletion_days
    )

    send_group_notice(recipient, component, deletion_days)
  end

  def canceled_subscription_deletion_warning(group_id, recipient_id, discarded_at)
    group = Group.discarded.find_by(id: group_id, discarded_at: discarded_at)
    recipient = group&.admins&.find_by(id: recipient_id)
    return unless recipient

    deletion_days = AppConfig.discarded_group_deletion_after_days
    component = Views::GroupMailer::CanceledSubscriptionDeletionWarning.new(
      group: group, usage: GroupUsageSummary.for(group), deletion_days: deletion_days
    )
    send_group_notice(recipient, component, deletion_days)
  end

  private

  def send_group_notice(recipient, component, deletion_days)
    subject_key = deletion_days ? "subject" : "unavailable_subject"
    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) do
      I18n.t("group_mailer.destroy_warning_with_usage.#{subject_key}")
    end
  end
end
