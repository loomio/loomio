class Slack::PollClosedSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.poll_closed", title: object.title, url: poll_url(object, default_url_options))
  end
end
