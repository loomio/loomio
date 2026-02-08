# frozen_string_literal: true

class Views::EventMailer::EventLayout < Views::BaseMailer::Base

  def around_template(&)
    doctype
    html do
      head { stylesheet_link_tag 'email' }
      body(class: "max-width-600") do
        raw EventMailer::REPLY_DELIMITER.html_safe
        main(class: "base-mailer__body") do
          super
        end
      end
    end
  end
end
