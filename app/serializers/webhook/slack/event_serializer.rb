class Webhook::Slack::EventSerializer < Webhook::Markdown::EventSerializer
  def text
    ApplicationController.renderer.render(
      layout: nil,
      template: "chatbot/slack/#{scope[:template_name]}",
      assigns: { poll: object.eventable.poll, event: object } )
  end
end
