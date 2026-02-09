# frozen_string_literal: true

class Views::MergeUsers::Complete < Views::BasicLayout
  def initialize(target_user:, **layout_args)
    super(**layout_args)
    @target_user = target_user
  end

  def view_template
    h1(class: "header") { plain t(:"user_mailer.merge_verification.complete_page.title") }
    p { plain t(:"user_mailer.merge_verification.complete_page.body_html", target_email: @target_user.email) }
  end
end
