class Slack::Ephemeral::PollNotFoundSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.poll_not_found")
  end
end
