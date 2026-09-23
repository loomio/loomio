class Webhook::Slack::TopicItemSerializer < Webhook::Markdown::TopicItemSerializer
  def include_icon_url?
    false
  end

  def include_username?
    false
  end

  def text
    I18n.with_locale(object.itemable.group.locale) do
      poll = %w[Poll Stance Outcome].include?(object.itemable_type) ? object.itemable.poll : nil
      component = ChatbotService.slack_component(
        scope[:template_name],
        topic_item: object,
        poll: poll,
        recipient: scope[:recipient]
      )
      ApplicationController.renderer.render(component, layout: false)
    end
  end
end
