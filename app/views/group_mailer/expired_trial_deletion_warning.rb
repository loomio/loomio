# frozen_string_literal: true

class Views::GroupMailer::ExpiredTrialDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, recipient:, usage:)
    @group = group
    @recipient = recipient
    @usage = usage
  end

  def view_template
    p { plain t("group_mailer.destroy_warning_with_usage.trial_expired_warning", group: @group.name, expired_days: expired_days, grace_days: AppConfig.group_deletion_delay_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.trial_expired_process", grace_days: AppConfig.group_deletion_delay_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.usage_heading") }
    usage_list
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def expired_days
    (Time.zone.today - @group.subscription.expires_at.to_date).to_i
  end

  def usage_list
    ul do
      %i[subgroups members discussions polls comments].each do |name|
        li { plain "#{t("group_mailer.destroy_warning_with_usage.#{name}")}: #{@usage.fetch(name)}" }
      end
    end
  end
end
