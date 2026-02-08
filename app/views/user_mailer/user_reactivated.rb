# frozen_string_literal: true

class Views::UserMailer::UserReactivated < Views::BaseMailer::Base

  def initialize(user:, token:, utm_hash:)
    @user = user
    @token = token
    @utm_hash = utm_hash
  end

  def view_template
    name = @user[:name] || @user.email

    div(class: "center") do
      p(class: "user-mailer__context") do
        plain t(:"email.reactivate.intro", name: name, site_name: AppConfig.theme[:site_name])
      end
      p(class: "user-mailer__message-container") do
        link_to t(:"email.reactivate.login", name: name, site_name: AppConfig.theme[:site_name]),
          login_token_url(@token.token, @utm_hash),
          data: { "skip-click": true },
          class: "base-mailer__button base-mailer__button--primary"
      end
      p(class: "user-mailer__code-helptext") { plain t(:"email.common.or_enter_code") }
      p(class: "user-mailer__code") { plain @token.code }
      p(class: "user-mailer__resend") do
        span { plain t(:"email.common.resend") }
      end
    end
  end
end
