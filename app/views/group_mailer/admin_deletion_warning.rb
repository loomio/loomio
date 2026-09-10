# frozen_string_literal: true

class Views::GroupMailer::AdminDeletionWarning < Views::ApplicationMailer::BaseLayout
  def initialize(group:, recipient:, requestor:, usage:)
    @group = group
    @recipient = recipient
    @requestor = requestor
    @usage = usage
  end

  def view_template
    p { plain t("group_mailer.destroy_warning_with_usage.requested", group: @group.name, requestor: @requestor.name, days: AppConfig.group_deletion_delay_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.usage_heading") }
    usage_list
    p { plain t(:"group_mailer.destroy_warning_with_usage.export", days: AppConfig.group_deletion_delay_days) }
    p { plain t(:"group_mailer.destroy_warning_with_usage.group_key", key: @group.key) }
  end

  private

  def usage_list
    ul do
      %i[subgroups members discussions polls comments].each do |name|
        li { plain "#{t("group_mailer.destroy_warning_with_usage.#{name}")}: #{@usage.fetch(name)}" }
      end
    end
  end
end
