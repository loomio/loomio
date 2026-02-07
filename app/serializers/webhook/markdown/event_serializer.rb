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
      poll = %w[Poll Stance Outcome].include?(object.eventable_type) ? object.eventable.poll : nil
      component = ChatbotService.markdown_component(
        scope[:template_name],
        event: object,
        poll: poll,
        recipient: scope[:recipient]
      )
      ApplicationController.renderer.render(component, layout: false)
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
