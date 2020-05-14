class Slack::Ephemeral::UserNotFoundSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: CGI.unescape(object))
  end
end
