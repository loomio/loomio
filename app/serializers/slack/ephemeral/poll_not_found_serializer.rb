class Slack::Ephemeral::PollClosedSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.poll_not_found")
  end

  def model
    object
  end
end
