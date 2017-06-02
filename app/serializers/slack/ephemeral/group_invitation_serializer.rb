class Slack::Ephemeral::GroupInvitationSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: slack_link_for(model, invitation: true))
  end

  private

  def model
    @model ||= object.group
  end
end
