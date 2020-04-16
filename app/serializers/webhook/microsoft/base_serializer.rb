class Webhook::Microsoft::BaseSerializer < Webhook::Markdown::BaseSerializer
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

  def sections
    []
    # [{
    #   activityTitle:    "[#{section_title}](#{section_url})",
    #   activitySubtitle: section_subtitle,
    #   activityImage:    section_image,
    #   facts:            section_facts,
    #   markdown:         true
    # }]
  end

  def section_title
    text_options[:title]
  end

  def section_url
    text_options[:url]
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
end
