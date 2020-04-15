class Webhook::Slack::Ephemeral::UserNotFoundSerializer < Webhook::Slack::BaseSerializer
  include Webhook::Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: URI.unescape(object))
  end
end
