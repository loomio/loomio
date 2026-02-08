# frozen_string_literal: true

class Views::MergeUsers::Confirm < Views::BasicLayout
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTag

  def initialize(source_user:, target_user:, hash:, **layout_args)
    super(**layout_args)
    @source_user = source_user
    @target_user = target_user
    @hash = hash
  end

  def view_template
    h1 { plain t(:"user_mailer.merge_verification.confirm_page.confirm") }
    p { plain t(:"user_mailer.merge_verification.confirm_page.body_html", target_email: @target_user.email, source_email: @source_user.email) }
    form_with(url: helpers.merge_users_merge_url(source_id: @source_user.id, target_id: @target_user.id, hash: @hash), method: :post, class: "application-form") do
      button_tag(t(:"user_mailer.merge_verification.confirm_page.merge"), class: "btn--accent--raised mt-12")
    end
  end
end
