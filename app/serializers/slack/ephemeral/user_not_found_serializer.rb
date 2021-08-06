class Slack::Ephemeral::UserNotFoundSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.request_authorization_message", url: URI.decode_www_form_component(object))
  end
end
