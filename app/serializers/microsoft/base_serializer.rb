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
      activityTitle:    "[#{section_title}](#{section_url})",
      activitySubtitle: section_subtitle,
      activityImage:    section_image,
      facts:            section_facts,
      markdown:         true
    }]
  end

  def section_title
    object.eventable.title
  end

  def section_url
    polymorphic_url(object.eventable, default_url_options)
  end

  def section_subtitle
    object.eventable.description
  end

  def section_image
    user.absolute_avatar_url
  end

  def section_facts
    []
  end

  private

  def text_options
    {
      author: user.name,
      group:  object.group.full_name
    }
  end

  def user
    object.user || object.eventable.user
  end
end
