# frozen_string_literal: true

class Views::NotificationMailer::Poll::ShareOutcome < Views::ApplicationMailer::Component

  def initialize(topic_item:, recipient:)
    @topic_item = topic_item
    @recipient = recipient
    @poll = topic_item.itemable.poll
  end

  def view_template
    return unless @poll.closed_at && !@poll.current_outcome

    p(class: "poll-mailer__create_outcome text-center") do
      render Views::NotificationMailer::Common::Button.new(
        url: tracked_url(@poll, recipient: @recipient, args: { set_outcome: @poll.id }),
        text: t('poll_mailer.common.create_outcome')
      )
    end
  end
end
