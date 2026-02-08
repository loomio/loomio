# frozen_string_literal: true

class Views::GroupMailer::DestroyWarning < Views::BaseMailer::BaseLayout

  def initialize(group:, recipient:, deletor:)
    @group = group
    @recipient = recipient
    @deletor = deletor
  end

  def view_template
    p { plain t(:"group_mailer.destroy_warning.body", group: @group.name, deletor: @deletor.name) }
    p { plain "Group key: #{@group.key}" }
  end
end
