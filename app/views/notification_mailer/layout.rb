# frozen_string_literal: true

class Views::NotificationMailer::Layout < Views::ApplicationMailer::Component

  def around_template(&)
    doctype
    html do
      head { render_email_head }
      body(class: "email-body") do
        raw NotificationMailer::REPLY_DELIMITER.html_safe
        main do
          super
        end
      end
    end
  end
end
