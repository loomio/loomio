# frozen_string_literal: true

class Views::EmailChanges::Confirm < Views::BasicLayout
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTag

  def initialize(user:, token:, **layout_args)
    super(**layout_args)
    @user = user
    @token = token
  end

  def view_template
    main(class: 'sistema') do
      h1 { plain t(:'email_changes.confirm_title') }
      p { plain t(:'email_changes.confirm_body', email: @user.email_change_pending) }
      form_with(url: email_changes_apply_path(user_id: @user.id, token: @token), method: :post, class: 'application-form') do
        button_tag(t(:'email_changes.confirm_action'), class: 'btn--accent--raised mt-12')
      end
    end
  end
end
