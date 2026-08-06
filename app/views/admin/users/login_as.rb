# frozen_string_literal: true

class Views::Admin::Users::LoginAs < Views::Admin::Layout
  def initialize(user:, token:)
    super(title: "Sign in as #{user.name}")
    @user = user
    @token = token
  end

  def view_template
    page_header("Sign in as #{@user.name}")
    panel("One-time login link") do
      p { "Open this link in a private browser window:" }
      p { link_to "Sign in as #{@user.email}", login_token_url(@token.token), target: "_blank", rel: "noopener" }
    end
  end
end
