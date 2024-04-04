class Webhook::Markdown::EventSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  
  attributes :text,
             :icon_url,
             :username

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

  def user
    object.user || object.eventable.author
  end

  def eventable
    object.eventable
  end
end
