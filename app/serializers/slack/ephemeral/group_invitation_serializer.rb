class Slack::Ephemeral::GroupInvitationSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: slack_link_for(object.group, invitation: true))
  end

  private

  def group
    @group ||= object.group
  end
end
