# frozen_string_literal: true

class Views::UserMailer::UserReactivated < Views::ApplicationMailer::Component

  def initialize(user:, token:, utm_hash:)
    @user = user
    @token = token
    @utm_hash = utm_hash
  end

  def view_template
    name = @user[:name] || @user.email

    div(class: "email-login") do
      p do
        plain t(:"email.reactivate.intro", name: name, site_name: AppConfig.theme[:site_name])
      end
      p(class: "email-login-action") do
        link_to t(:"email.reactivate.login", name: name, site_name: AppConfig.theme[:site_name]),
          login_token_url(@token.token, @utm_hash),
          data: { "skip-click": true },
          class: "email-button email-button-primary"
      end
      p { plain t(:"email.common.or_enter_code") }
      p(class: "email-login-code") { plain @token.code }
      p do
        span { plain t(:"email.common.resend") }
      end
    end
  end
end
