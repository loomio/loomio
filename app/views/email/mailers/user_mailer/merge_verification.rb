# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::MergeVerification < Views::Email::BaseLayout

  def initialize(source_user:, target_user:, hash_value:)
    @source_user = source_user
    @target_user = target_user
    @hash_value = hash_value
  end

  def view_template
    div(class: "invite-people-mailer") do
      div(class: "invite-people-mailer__container") do
        div(class: "mailer__header") do
          div(class: "mailer__header-logo") do
            image_tag AppConfig.theme[:email_header_logo_src], alt: "Logo", class: "mailer__header-logo-image"
          end
        end
        div(class: "invite-people-mailer__body") do
          p do
            raw t(:"user_mailer.merge_verification.body_html",
              name: @target_user.name,
              target_email: @target_user.email,
              source_email: @source_user.email)
          end
          p do
            link_to t(:"user_mailer.merge_verification.verify"),
              merge_users_confirm_url(source_id: @source_user.id, target_id: @target_user.id, hash: @hash_value),
              class: "base-mailer__button base-mailer__button--accent"
          end
        end
      end
    end
  end
end
