class Slack::Ephemeral::RequestAuthorizationSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", object)
  end
end
