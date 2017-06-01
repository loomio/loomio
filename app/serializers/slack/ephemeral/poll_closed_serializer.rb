class Slack::Ephemeral::PollClosedSerializer < Slack::BaseSerializer
  include Slack::Ephemeral::Message

  def text
    I18n.t(:"slack.poll_closed", title: object.title, url: poll_url(object, default_url_options))
  end
end
