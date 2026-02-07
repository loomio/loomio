# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::Login < Views::Email::BaseLayout

  def initialize(user:, token:)
    @user = user
    @token = token
  end

  def view_template
    p(class: "user-mailer__context text-center") do
      plain t(:"email.login.intro_code", name: @user.email, site_name: AppConfig.theme[:site_name])
    end
    p(class: "user-mailer__code text-center") { plain @token.code }
    p(class: "user-mailer__resend text-center") do
      span { plain t(:"email.common.resend") }
    end
  end
end
