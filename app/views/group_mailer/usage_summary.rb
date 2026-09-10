# frozen_string_literal: true

class Views::GroupMailer::UsageSummary < Views::ApplicationMailer::Component
  def initialize(usage:)
    @usage = usage
  end

  def view_template
    p { plain t(:"group_mailer.destroy_warning_with_usage.usage_heading") }
    ul do
      %i[subgroups members discussions polls comments].each do |name|
        li { plain "#{t("group_mailer.destroy_warning_with_usage.#{name}")}: #{@usage.fetch(name)}" }
      end
    end
  end
end
