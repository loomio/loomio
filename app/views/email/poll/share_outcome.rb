# frozen_string_literal: true

class Views::Email::Poll::ShareOutcome < Views::Email::Base

  def initialize(event:)
    @event = event
    @poll = event.eventable.poll
  end

  def view_template
    return unless @poll.closed_at && !@poll.current_outcome

    p(class: "poll-mailer__create_outcome text-center") do
      render Views::Email::Common::Button.new(
        url: tracked_url(@poll, set_outcome: @poll.id),
        text: t('poll_mailer.common.create_outcome')
      )
    end
  end
end
