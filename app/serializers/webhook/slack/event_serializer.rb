class Webhook::Slack::EventSerializer < Webhook::Markdown::EventSerializer
  def include_icon_url?
    false
  end

  def include_username?
    false
  end

  def text
    I18n.with_locale(object.eventable.group.locale) do
      poll = %w[Poll Stance Outcome].include?(object.eventable_type) ? object.eventable.poll : nil
      component = ChatbotService.slack_component(
        scope[:template_name],
        event: object,
        poll: poll,
        recipient: scope[:recipient]
      )
      ApplicationController.renderer.render(component, layout: false)
    end
  end
end
