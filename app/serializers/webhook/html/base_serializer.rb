class Webhook::Html::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper

  attributes :text,
             :icon_url,
             :username,
             :kind,
             :url,
             :group_name,
             :actor_name,
             :poll_type,
             :title,
             :attachments

  def icon_url
    object.eventable.group.logo_url
  end

  def attachments
    object.eventable.attachments
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
    true
    # scope[:webhook] && scope[:webhook].include_body
  end

  def headline
    MarkdownService.render_html(I18n.t(:"notifications.with_title.#{object.kind}", text_options))
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
    }
  end

  def url
    polymorphic_url(eventable, default_url_options)
  end

  def actor_name
    user&.name || eventable.author.name
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

    render_rich_text(var, eventable.body_format)
  end

  def body_format
    eventable.body_format
  end

  def user
    object.user || object.eventable.author
  end

  def eventable
    object.eventable
  end

  def render_rich_text(text, format = "md")
    return "" unless text
    if format == "md"
      text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
      MarkdownService.render_html(text)
    else
      text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
    end
    text.html_safe
  end

  def render_plain_text(text, format = 'md')
    return "" unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format)).gsub(/(?:\n\r?|\r\n?)/, '<br>')
  end
end
