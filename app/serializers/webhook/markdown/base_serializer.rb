class Webhook::Markdown::BaseSerializer < ActiveModel::Serializer
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
             :attachments,
             :blocks

  def blocks
    (object.eventable.image_files.concat object.eventable.files).map do |file|
      if file.previewable?
        # url = Rails.application.routes.url_helpers.rails_representation_url(
        #   file.representation(HasRichText::PREVIEW_OPTIONS), host: ENV['CANONICAL_HOST']
        # )
        { type: 'image', image_url: file.blob.preview(HasRichText::PREVIEW_OPTIONS).processed.service_url, alt_text: 'image' }
      end
    end.compact
  end

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

    if body_format == 'html'
      var.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
      ReverseMarkdown.convert(var)
    else
      var.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
      var
    end
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
end
