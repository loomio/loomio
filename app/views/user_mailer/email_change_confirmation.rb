# frozen_string_literal: true

class Views::UserMailer::EmailChangeConfirmation < Views::ApplicationMailer::BaseLayout
  def initialize(user:, email:, token:)
    @user = user
    @email = email
    @token = token
  end

  def view_template
    p { plain t(:'user_mailer.email_change_confirmation.body', email: @email) }
    p do
      link_to t(:'user_mailer.email_change_confirmation.confirm'),
        email_changes_confirm_url(user_id: @user.id, token: @token),
        class: 'email-button email-button-accent'
    end
  end
end
