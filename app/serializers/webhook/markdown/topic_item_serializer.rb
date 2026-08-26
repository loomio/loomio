class Webhook::Markdown::TopicItemSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  
  attributes :text,
             :icon_url,
             :username

  def icon_url
    (root_url(host: ENV['CANONICAL_HOST']).chomp('/') + (object.group.self_or_parent_logo_url(128) || ''))
  end

  def attachments
    object.itemable.attachments
  end

  def username
    AppConfig.theme[:site_name]
  end

  def text
    I18n.with_locale(object.itemable.group.locale) do
      poll = %w[Poll Stance Outcome].include?(object.itemable_type) ? object.itemable.poll : nil
      component = ChatbotService.markdown_component(
        scope[:template_name],
        topic_item: object,
        poll: poll,
        recipient: scope[:recipient]
      )
      ApplicationController.renderer.render(component, layout: false)
    end
  end

  private

  def user
    object.user || object.itemable.author
  end

  def itemable
    object.itemable
  end
end
