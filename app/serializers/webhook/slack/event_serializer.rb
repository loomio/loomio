class Webhook::Slack::EventSerializer < Webhook::Markdown::EventSerializer
  def text
    SlackMrkdwn.from ApplicationController.renderer.render(
      layout: nil,
      template: "chatbot/markdown/#{scope[:template_name]}",
      assigns: { poll: object.eventable.poll, event: object } )
  end
end
