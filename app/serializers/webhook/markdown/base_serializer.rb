class Webhook::Markdown::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  include PollEmailHelper

  attributes :text

  def text
    I18n.t(:"webhook.markdown.#{object.kind}", text_options)
  end

  private

  def text_options
    {
      actor: user.name,
      title: title,
      body: body,
      url: polymorphic_url(eventable, default_url_options)
    }
  end

  def title
    eventable.title
  end

  def body
    if object.eventable.body_format == 'html'
      ReverseMarkdown.convert(eventable.body)
    else
      eventable.body
    end
  end

  def user
    anonymous_or_actor_for(object)
  end

  def eventable
    object.eventable
  end
end
