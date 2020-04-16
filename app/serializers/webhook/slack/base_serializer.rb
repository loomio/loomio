class Webhook::Slack::BaseSerializer < Webhook::Markdown::BaseSerializer
  def headline
    SlackMrkdwn.from(super)
  end

  def body
    SlackMrkdwn.from(super)
  end
end
