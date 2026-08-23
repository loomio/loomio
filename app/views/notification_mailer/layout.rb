# frozen_string_literal: true

class Views::NotificationMailer::Layout < Views::ApplicationMailer::Component

  def around_template(&)
    doctype
    html do
      head { render_email_head }
      body(class: "max-width-600") do
        raw NotificationMailer::REPLY_DELIMITER.html_safe
        main(class: "base-mailer__body") do
          super
        end
      end
    end
  end
end
