# frozen_string_literal: true

class Views::EmailChanges::Complete < Views::BasicLayout
  def initialize(user:, **layout_args)
    super(**layout_args)
    @user = user
  end

  def view_template
    main(class: 'sistema') do
      h1 { plain t(:'email_changes.complete_title') }
      p { plain t(:'email_changes.complete_body', email: @user.email) }
    end
  end
end
