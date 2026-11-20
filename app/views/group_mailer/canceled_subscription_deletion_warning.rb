# frozen_string_literal: true

class Views::GroupMailer::CanceledSubscriptionDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, usage:, deletion_days:)
    @group = group
    @usage = usage
    @deletion_days = deletion_days
  end

  def view_template
    introduction = @deletion_days ? "subscription_canceled" : "subscription_canceled_unavailable"
    recovery = @deletion_days ? "export" : "restore_or_export"
    p { plain t("group_mailer.destroy_warning_with_usage.#{introduction}", group: @group.name) }
    p { plain t("group_mailer.destroy_warning_with_usage.#{recovery}", days: @deletion_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t("group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end
end
