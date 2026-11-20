# frozen_string_literal: true

class Views::GroupMailer::AdminDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, requestor:, usage:, deletion_days:)
    @group = group
    @requestor = requestor
    @usage = usage
    @deletion_days = deletion_days
  end

  def view_template
    introduction = @deletion_days ? "requested" : "requested_unavailable"
    recovery = @deletion_days ? "export" : "restore_or_export"
    p { plain t("group_mailer.destroy_warning_with_usage.#{introduction}", group: @group.name, requestor: @requestor.name, days: @deletion_days) }
    render Views::GroupMailer::UsageSummary.new(usage: @usage)
    p { plain t("group_mailer.destroy_warning_with_usage.#{recovery}", days: @deletion_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end
end
