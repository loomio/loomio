# frozen_string_literal: true

class Views::EventMailer::Common::Body < Views::ApplicationMailer::Base

  def initialize(eventable:, recipient:)
    @eventable = eventable
    @recipient = recipient
  end

  def view_template
    div(class: "thread-mailer__body") do
      p { raw TranslationService.formatted_text(@eventable, :body, @recipient) }
      render Views::EventMailer::Common::Attachments.new(resource: @eventable)
    end
  end
end
