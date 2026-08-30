# frozen_string_literal: true

class Views::UserMailer::Digest::Footer < Views::ApplicationMailer::Component
  def initialize(recipient:)
    @recipient = recipient
  end

  def view_template
    div(class: "email-footer") do
      p do
        plain "\u2014"
        br
        a(

          href: email_preferences_url(unsubscribe_token: @recipient.unsubscribe_token)
        ) { plain t(:"common.action.unsubscribe") }
      end

      image_tag(
        AppConfig.theme[:email_footer_logo_src],
        height: 24,
        alt: "Logo",
        class: "email-footer-logo"
      )
    end
  end
end
