# frozen_string_literal: true

class Views::EventMailer::Common::TranslationNotice < Views::ApplicationMailer::Component

  def initialize(event:, recipient:)
    @event = event
    @recipient = recipient
  end

  def view_template
    return unless TranslationService.show_translation(@event.eventable, @recipient)

    p(class: "py-1") do
      # _html suffix makes Rails return SafeBuffer
      raw t(
        :'email.content_was_translated_html',
        profile_url: profile_url,
        source_locale: t(:"locale_names.#{@event.eventable.content_locale}")
      )
    end
  end
end
