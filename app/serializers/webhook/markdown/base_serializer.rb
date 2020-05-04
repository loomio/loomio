class Webhook::Markdown::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  include PollEmailHelper

  attributes :text,
             :icon_url,
             :username,
             :kind,
             :url,
             :group_name,
             :actor_name,
             :poll_type,
             :title

  def icon_url
    url = object.eventable.group.logo.url(:medium)
    if url.starts_with?('http')
      url
    else
      "https://#{ENV['CANONICAL_HOST']}#{url}"
    end
  end

  def username
    AppConfig.theme[:site_name]
  end

  def text
    if has_body
      headline + "\n\n" + body.to_s
    else
      headline
    end
  end

  def has_body
    scope[:webhook] && scope[:webhook].include_body
  end

  def headline
    I18n.t(:"webhook.markdown.#{object.kind}", text_options)
  end

  private

  def text_options
    {
      actor: actor_name,
      title: title,
      body: body,
      url: url,
      poll_type: poll_type,
      group: group_name
    }.compact
  end

  def url
    polymorphic_url(eventable, default_url_options)
  end

  def actor_name
    user.name
  end

  def group_name
    eventable.group.name
  end

  def poll_type
    if object.eventable.respond_to?(:poll)
      I18n.t("poll_types.#{object.eventable.poll.poll_type}")
    else
      nil
    end
  end

  def title
    eventable.title
  end

  def body
    if eventable.is_a? Outcome
      var = eventable.statement
    else
      var = eventable.body
    end

    if body_format == 'html'
      ReverseMarkdown.convert(var)
    else
      var
    end
  end

  def body_format
    eventable.body_format
  end

  def user
    anonymous_or_actor_for(object)
  end

  def eventable
    object.eventable
  end
end
