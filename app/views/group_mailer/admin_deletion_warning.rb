# frozen_string_literal: true

class Views::GroupMailer::AdminDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, requestor:, usage:)
    @group = group
    @requestor = requestor
    @usage = usage
  end

  def view_template
    p { plain t("group_mailer.destroy_warning_with_usage.requested", group: @group.name, requestor: @requestor.name, days: AppConfig.group_deletion_delay_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t(:"group_mailer.destroy_warning_with_usage.export", days: AppConfig.group_deletion_delay_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end
end
