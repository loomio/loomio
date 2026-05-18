# frozen_string_literal: true

class Views::EventMailer::Poll::Summary < Views::ApplicationMailer::Component

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    div(class: "poll-mailer-common-summary") do
      if @poll.current_outcome
        h2(class: "text-subtitle-2") { plain t(:"poll_common.outcome") }
        p { raw TranslationService.formatted_text(@poll.current_outcome, :statement, @recipient) }
        h2(class: "text-subtitle-2") { plain t(:"decision_tools_card.#{@poll.poll_type}_title") }
      end

      p { raw TranslationService.formatted_text(@poll, :details, @recipient) }

      render Views::EventMailer::Common::Attachments.new(resource: @poll)
    end
  end
end
