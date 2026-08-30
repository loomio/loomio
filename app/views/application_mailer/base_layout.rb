# frozen_string_literal: true

class Views::ApplicationMailer::BaseLayout < Views::ApplicationMailer::Component

  def around_template(&)
    doctype
    html do
      head { render_email_head }
      body(class: "email-body") do
        div(class: "email-header") do
          div(class: "email-header-logo") do
            image_tag AppConfig.theme[:email_header_logo_src],
              alt: AppConfig.theme[:site_name],
              class: "email-header-logo-image",
              width: 256
          end
        end
        super
      end
    end
  end
end
