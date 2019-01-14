class Microsoft::BaseSerializer < ActiveModel::Serializer
  include PrettyUrlHelper
  attribute :type, key: :"@type"
  attribute :context, key: :"@context"
  attribute :theme_color, key: :themeColor
  attributes :text, :sections

  def type
    "MessageCard"
  end

  def context
    "http://schema.org/extensions"
  end

  def theme_color
    AppConfig.theme[:primary_color]
  end

  def text
    I18n.t(:"microsoft.#{object.kind}", text_options)
  end

  def sections
    [{
      activityTitle:    section_title,
      activitySubtitle: section_subtitle,
      activityImage:    section_image,
      facts:            section_facts,
      markdown:         true
    }]
  end

  def section_title
    "[#{object.eventable.title}](#{polymorphic_url(object.eventable, default_url_options)})"
  end

  def section_subtitle
    object.eventable.description
  end

  def section_image
    user_avatar_url object.user
  end

  def section_facts
    [{
      name: I18n.t(:"microsoft.authored_by"),
      value: object.user.name
    }, {
      name: I18n.t(:"microsoft.created_at"),
      value: object.created_at
    }]
  end

  private

  def text_options
    {
      author: object.user.name,
      group:  object.group.full_name
    }
  end
end
