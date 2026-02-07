# frozen_string_literal: true

class Views::Email::BaseLayout < Views::Email::Base

  def around_template(&)
    doctype
    html do
      head { stylesheet_link_tag 'email' }
      body(class: "max-width-600") do
        div(class: "mailer__header") do
          div(class: "mailer__header-logo") do
            image_tag AppConfig.theme[:email_header_logo_src],
              alt: AppConfig.theme[:site_name],
              class: "mailer__header-logo-image",
              width: 256
          end
        end
        super
      end
    end
  end
end
