# frozen_string_literal: true

class Views::EventMailer::Group::CoverAndLogo < Views::ApplicationMailer::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    return unless @group.present?

    cover_url = base_url.chomp('/') + (@group.self_or_parent_cover_url(300) || '')
    logo_url = base_url.chomp('/') + (@group.self_or_parent_logo_url(128) || '')

    table(
      style: "padding: 0; margin-bottom: 8px",
      class: "container",
      role: "presentation",
      cellpadding: 0,
      cellspacing: 0,
      border: 0,
      width: 600,
      height: 150
    ) do
      tr do
        td(
          class: "rounded",
          valign: "bottom",
          style: "background: url(#{cover_url}) #ffffff; background-size:cover; background-position:center;"
        ) do
          raw "<!--[if mso]><img src=\"#{cover_url}\" height=\"150\" width=\"600\"><![endif]-->".html_safe
          raw "<!--[if !mso]><!-->".html_safe
          if @group.logo_url
            img(
              class: "rounded",
              style: "width: 64px; height: 64px; margin-left: 8px; margin-bottom: 4px",
              src: logo_url,
              height: 64,
              width: 64
            )
          end
          raw "<!--<![endif]-->".html_safe
        end
      end
    end
  end

  private

  def base_url
    host = ENV.fetch('CANONICAL_HOST', 'localhost:3000')
    host =~ /^http/ ? host : "https://#{host}"
  end
end
