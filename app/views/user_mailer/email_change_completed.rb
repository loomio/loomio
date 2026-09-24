# frozen_string_literal: true

class Views::UserMailer::EmailChangeCompleted < Views::ApplicationMailer::BaseLayout
  def initialize(old_email:, new_email:)
    @old_email = old_email
    @new_email = new_email
  end

  def view_template
    p { plain t(:'user_mailer.email_change_completed.body', old_email: @old_email, new_email: @new_email) }
  end
end
