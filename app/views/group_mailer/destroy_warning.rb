# frozen_string_literal: true

class Views::GroupMailer::DestroyWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, recipient:, requestor:, reason:, usage:)
    @group = group
    @recipient = recipient
    @requestor = requestor
    @reason = reason
    @usage = usage
  end

  def view_template
    p { plain warning_body }
    p { plain warning_process } if trial_expired?
    p { plain t(:"group_mailer.destroy_warning_with_usage.usage_heading") }
    ul do
      %i[subgroups members discussions polls comments].each do |name|
        li { plain "#{t("group_mailer.destroy_warning_with_usage.#{name}")}: #{@usage.fetch(name)}" }
      end
    end
    p { plain t(:"group_mailer.destroy_warning_with_usage.export", days: AppConfig.group_deletion_grace_days) } unless trial_expired?
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def warning_body
    key = trial_expired? ? :trial_expired_warning : :requested
    t(
      "group_mailer.destroy_warning_with_usage.#{key}",
      group: @group.name,
      requestor: @requestor&.name,
      days: AppConfig.group_deletion_grace_days,
      expired_days: trial_expired_days,
      grace_days: AppConfig.group_deletion_grace_days
    )
  end

  def warning_process
    t(
      :"group_mailer.destroy_warning_with_usage.trial_expired_process",
      grace_days: AppConfig.group_deletion_grace_days
    )
  end

  def trial_expired?
    @reason == "trial_expired"
  end

  def trial_expired_days
    return unless trial_expired?

    (Time.zone.today - @group.subscription.expires_at.to_date).to_i
  end
end
