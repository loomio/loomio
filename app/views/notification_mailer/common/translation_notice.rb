# frozen_string_literal: true

class Views::NotificationMailer::Common::TranslationNotice < Views::ApplicationMailer::Component

  def initialize(topic_item:, recipient:)
    @topic_item = topic_item
    @recipient = recipient
  end

  def view_template
    return unless TranslationService.show_translation(@topic_item.itemable, @recipient)

    p(class: "py-1") do
      # _html suffix makes Rails return SafeBuffer
      raw t(
        :'email.content_was_translated_html',
        profile_url: profile_url,
        source_locale: t(:"locale_names.#{@topic_item.itemable.content_locale}")
      )
    end
  end
end
