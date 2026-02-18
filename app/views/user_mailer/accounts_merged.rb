# frozen_string_literal: true

class Views::UserMailer::AccountsMerged < Views::ApplicationMailer::BaseLayout

  def initialize(user:, token:, utm_hash:)
    @user = user
    @token = token
    @utm_hash = utm_hash
  end

  def view_template
    p do
      raw t(:"user_mailer.accounts_merged.body_html", name: @user.name, email: @user.email)
    end
    p do
      link_to t(:"email.login.login", name: @user.email),
        login_token_url(@token.token, @utm_hash),
        class: "base-mailer__button base-mailer__button--accent"
    end
  end
end
