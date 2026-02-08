# frozen_string_literal: true

class Views::EventMailer::Common::Button < Views::BaseMailer::Base
  def initialize(url:, text:)
    @url = url
    @text = text
  end

  def view_template
    bgcolor = AppConfig.theme[:primary_color]
    fgcolor = "#ffffff"

    a(
      class: "base-mailer__button",
      href: @url,
      style: "background-color: #{bgcolor}; font-size: 18px; font-weight: bold; text-decoration: none; padding: 12px 24px; color: #{fgcolor}; border-radius: 5px; display: inline-block; mso-padding-alt: 0;"
    ) do
      raw mso_open_comment(<<~MSO)
        <i style="letter-spacing: 25px; mso-font-width: -100%; mso-text-raise: 30pt;">&nbsp;</i>
      MSO
      span(style: "mso-text-raise: 15pt; color: #{fgcolor}") { plain @text }
      raw mso_close_comment(<<~MSO)
        <i style="letter-spacing: 25px; mso-font-width: -100%;">&nbsp;</i>
      MSO
    end
  end

  private

  def mso_open_comment(content)
    "<!--[if mso]>#{content.strip}<![endif]-->".html_safe
  end

  def mso_close_comment(content)
    "<!--[if mso]>#{content.strip}<![endif]-->".html_safe
  end
end
