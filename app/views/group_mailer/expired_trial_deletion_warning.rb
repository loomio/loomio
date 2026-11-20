# frozen_string_literal: true

class Views::GroupMailer::ExpiredTrialDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, usage:, catch_up:, deletion_days:)
    @group = group
    @usage = usage
    @catch_up = catch_up
    @deletion_days = deletion_days
  end

  def view_template
    reason = @catch_up ? "trial_catch_up" : "trial_expired"
    introduction = @deletion_days ? "#{reason}_warning" : "#{reason}_unavailable"
    recovery = @deletion_days ? "trial_expired_process" : "restore_or_export"
    days_since_expiry = expired_days unless @catch_up
    p { plain t("group_mailer.destroy_warning_with_usage.#{introduction}", group: @group.name, expired_days: days_since_expiry) }
    p { plain t("group_mailer.destroy_warning_with_usage.#{recovery}", grace_days: @deletion_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def expired_days
    (Time.zone.today - @group.subscription.expires_at.to_date).to_i
  end
end
