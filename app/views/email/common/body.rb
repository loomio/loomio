# frozen_string_literal: true

class Views::Email::Common::Body < Views::Email::Base

  def initialize(eventable:, recipient:)
    @eventable = eventable
    @recipient = recipient
  end

  def view_template
    div(class: "thread-mailer__body") do
      p { raw TranslationService.formatted_text(@eventable, :body, @recipient) }
      render Views::Email::Common::Attachments.new(resource: @eventable)
    end
  end
end
