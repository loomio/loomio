class Webhook::Slack::BaseSerializer < Webhook::Markdown::BaseSerializer
  def text
    I18n.t(:"webhook.markdown.#{object.kind}", text_options)
  end

  private

  def body
    if object.eventable.body_format == 'html'
      ReverseMarkdown.convert(eventable.body)
    else
      eventable.body
    end
  end
end
