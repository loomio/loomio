class Slack::Ephemeral::PollClosedSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.poll_closed", title: object.title, url: slack_link_for(poll))
  end
end
