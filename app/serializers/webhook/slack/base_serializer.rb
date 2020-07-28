class Webhook::Slack::BaseSerializer < Webhook::Markdown::BaseSerializer
  def headline
    SlackMrkdwn.from(super.to_s)
  end

  def body
    SlackMrkdwn.from(super.to_s)
  end
end
