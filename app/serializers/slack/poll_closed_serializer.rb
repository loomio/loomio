class Slack::PollClosedSerializer < Slack::BaseSerializer
  include Slack::EphemeralMessage

  def text
    I18n.t(:"slack.join_loomio_group", title: object.title, url: poll_url(object, default_url_options))
  end
end
