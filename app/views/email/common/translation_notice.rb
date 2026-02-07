# frozen_string_literal: true

class Views::Email::Common::TranslationNotice < Views::Email::Base

  def initialize(event:)
    @event = event
  end

  def view_template
    return unless show_translation(@event.eventable)

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
