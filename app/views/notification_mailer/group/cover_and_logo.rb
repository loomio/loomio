# frozen_string_literal: true

class Views::NotificationMailer::Group::CoverAndLogo < Views::ApplicationMailer::Component
  def initialize(group:)
    @group = group
  end

  def view_template
    return unless @group.present?

    cover_url = base_url.chomp('/') + (@group.self_or_parent_cover_url(300) || '')

    table(
      class: "email-group-cover",
      cellpadding: 0,
      cellspacing: 0,
      border: 0,
      width: 600,
      height: 150
    ) do
      tr do
        td(
          class: "email-group-cover-image",
          valign: "bottom",
          style: "background-image: url(#{cover_url}); background-position: center; background-size: cover"
        ) do
          raw "<!--[if mso]><img src=\"#{cover_url}\" height=\"150\" width=\"600\"><![endif]-->".html_safe
        end
      end
    end
  end

  private

  def base_url
    Rails.application.config.action_mailer.asset_host.to_s
  end
end
