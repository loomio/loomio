# frozen_string_literal: true

class Views::GroupMailer::ExpiredTrialDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, usage:, catch_up:)
    @group = group
    @usage = usage
    @catch_up = catch_up
  end

  def view_template
    if @catch_up
      p { plain t("group_mailer.destroy_warning_with_usage.trial_catch_up_warning", group: @group.name) }
    else
      p { plain t("group_mailer.destroy_warning_with_usage.trial_expired_warning", group: @group.name, expired_days: expired_days, grace_days: AppConfig.group_deletion_delay_days) }
    end
    p { plain t(:"group_mailer.destroy_warning_with_usage.trial_expired_process", grace_days: AppConfig.group_deletion_delay_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def expired_days
    (Time.zone.today - @group.subscription.expires_at.to_date).to_i
  end
end
