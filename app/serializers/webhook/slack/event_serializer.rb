class Webhook::Slack::EventSerializer < Webhook::Markdown::EventSerializer
  def text
    I18n.with_locale(object.eventable.group.locale) do
      ApplicationController.renderer.render(
        layout: nil,
        template: "chatbot/slack/#{scope[:template_name]}",
        assigns: { poll: object.eventable.poll, event: object } )
    end
  end
end
