# frozen_string_literal: true

class Views::NotificationMailer::Poll::Summary < Views::ApplicationMailer::Component

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    div do
      if @poll.current_outcome
        p { strong { plain t(:"poll_common.outcome") } }
        div(class: "email-user-content") { raw TranslationService.formatted_text(@poll.current_outcome, :statement, @recipient) }
        p { strong { plain t(:"decision_tools_card.#{@poll.poll_type}_title") } }
      end

      div(class: "email-user-content") { raw TranslationService.formatted_text(@poll, :details, @recipient) }

      render Views::NotificationMailer::Common::Attachments.new(resource: @poll)
    end
  end
end
