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
    p { plain t(:"group_mailer.destroy_warning_with_usage.usage_heading") }
    ul do
      %i[subgroups members discussions polls comments].each do |name|
        li { plain "#{t("group_mailer.destroy_warning_with_usage.#{name}")}: #{@usage.fetch(name)}" }
      end
    end
    p { plain t(:"group_mailer.destroy_warning_with_usage.export", days: AppConfig.group_deletion_grace_days) }
    p do
      link_to t(:"group_mailer.destroy_warning_with_usage.export_link"),
              "https://help.loomio.org/en/user_manual/groups/data_export/"
    end
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def warning_body
    key = @reason == "trial_expired" ? :trial_expired : :requested
    t(
      "group_mailer.destroy_warning_with_usage.#{key}",
      group: @group.name,
      requestor: @requestor&.name,
      days: AppConfig.group_deletion_grace_days
    )
  end
end
