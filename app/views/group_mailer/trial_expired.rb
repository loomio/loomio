# frozen_string_literal: true

class Views::GroupMailer::TrialExpired < Views::ApplicationMailer::BaseLayout

  def initialize(group:, recipient:)
    @group = group
    @recipient = recipient
  end

  def view_template
    p { plain t(:"group_mailer.trial_expired.body", group: @group.name) }
    p { plain "Group key: #{@group.key}" }
  end
end
