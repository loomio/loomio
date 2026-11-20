# frozen_string_literal: true

class Views::GroupMailer::CanceledSubscriptionDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, usage:)
    @group = group
    @usage = usage
  end

  def view_template
    p { plain t("group_mailer.destroy_warning_with_usage.subscription_canceled", group: @group.name) }
    p { plain t("group_mailer.destroy_warning_with_usage.export", days: AppConfig.group_deletion_delay_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t("group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end
end
