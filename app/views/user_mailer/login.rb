# frozen_string_literal: true

class Views::UserMailer::Login < Views::ApplicationMailer::BaseLayout

  def initialize(user:, token:)
    @user = user
    @token = token
  end

  def view_template
    div(class: "email-login") do
      p do
        plain t(:"email.login.intro_code", name: @user.email, site_name: AppConfig.theme[:site_name])
      end
      p(class: "email-login-code") { plain @token.code }
      p do
        span { plain t(:"email.common.resend") }
      end
    end
  end
end
