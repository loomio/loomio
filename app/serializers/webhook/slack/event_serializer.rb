class Webhook::Slack::EventSerializer < Webhook::Markdown::EventSerializer
  def include_icon_url?
    false
  end

  def include_username?
    false
  end

  def text
    I18n.with_locale(object.eventable.group.locale) do
      ApplicationController.renderer.render(
        layout: nil,
        template: "chatbot/slack/#{scope[:template_name]}",
        assigns: { poll: object.eventable.poll, event: object, recipient: scope[:recipient] } )
    end
  end
end
