# frozen_string_literal: true

class Views::EventMailer::Common::Title < Views::BaseMailer::Base

  def initialize(eventable:, recipient:)
    @eventable = eventable
    @recipient = recipient
  end

  def view_template
    h1(class: "text-h4 event-mailer__title") do
      a(href: tracked_url(@eventable, recipient: @recipient)) { plain TranslationService.plain_text(@eventable, :title, @recipient) }
    end
  end
end
