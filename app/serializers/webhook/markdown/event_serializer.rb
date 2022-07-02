class Webhook::Markdown::EventSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  
  attributes :text,
             :icon_url,
             :username,
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
    (root_url(host: ENV['CANONICAL_HOST']).chomp('/') + (object.group.self_or_parent_logo_url(128) || ''))
  end

  def attachments
    object.eventable.attachments
  end

  def username
    AppConfig.theme[:site_name]
  end

  def text
    I18n.with_locale(object.eventable.group.locale) do
      ApplicationController.renderer.render(
        layout: nil,
        template: "chatbot/markdown/#{scope[:template_name]}",
        assigns: { poll: object.eventable.poll, event: object, recipient: scope[:recipient] } )
    end
  end

  private

  # def body
  #   if eventable.is_a? Outcome
  #     var = eventable.statement
  #   else
  #     var = eventable.body
  #   end

  #   if body_format == 'html'
  #     var.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
  #     ReverseMarkdown.convert(var)
  #   else
  #     var.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
  #     var
  #   end
  # end

  # def body_format
  #   eventable.body_format
  # end

  def user
    object.user || object.eventable.author
  end

  def eventable
    object.eventable
  end
end
