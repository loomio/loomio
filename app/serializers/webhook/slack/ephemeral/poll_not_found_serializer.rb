class Webhook::Slack::Ephemeral::PollNotFoundSerializer < Webhook::Slack::BaseSerializer
  include Webhook::Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.poll_not_found")
  end
end
