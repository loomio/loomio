# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::Redacted < Views::Email::BaseLayout

  def view_template
    p do
      raw t(:"user_mailer.redacted.body_html",
        support_email: ENV['SUPPORT_EMAIL'],
        site_name: ENV['SITE_NAME'])
    end
  end
end
