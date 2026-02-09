# frozen_string_literal: true

class Views::EventMailer::Poll::ShareOutcome < Views::ApplicationMailer::Component

  def initialize(event:, recipient:)
    @event = event
    @recipient = recipient
    @poll = event.eventable.poll
  end

  def view_template
    return unless @poll.closed_at && !@poll.current_outcome

    p(class: "poll-mailer__create_outcome text-center") do
      render Views::EventMailer::Common::Button.new(
        url: tracked_url(@poll, recipient: @recipient, args: { set_outcome: @poll.id }),
        text: t('poll_mailer.common.create_outcome')
      )
    end
  end
end
