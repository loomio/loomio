# frozen_string_literal: true

class Views::UserMailer::UnsubscribeLink < Views::ApplicationMailer::Component

  def initialize(recipient:)
    @recipient = recipient
  end

  def view_template
    br
    p(class: "unsubscribe") do
      raw t("email.unsubscribe_html",
        link_text: t(:"catch_up.click_here"),
        link_path: email_preferences_url(unsubscribe_token: @recipient.unsubscribe_token))
    end
  end
end
