# frozen_string_literal: true

class Views::EventMailer::Poll::Summary < Views::BaseMailer::Base

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

      if @poll.active?
        p { plain t(:"poll_mailer.common.you_have_until", when: format_date_for_humans(@poll.closing_at, @recipient.time_zone, @recipient.date_time_pref)) }
      end

      if @poll.closed?
        h3(class: "text-subtitle-2") do
          plain t(:"poll_common_form.closed")
          plain " "
          plain format_date_for_humans(@poll.closed_at, @recipient.time_zone, @recipient.date_time_pref)
        end
      end

      render Views::EventMailer::Common::Attachments.new(resource: @poll)
    end
  end
end
