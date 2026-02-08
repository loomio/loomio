# frozen_string_literal: true

class Views::EventMailer::Stance < Views::EventMailer::EventLayout

  def initialize(event:, recipient:, event_key:, notification: nil, discussion: nil, poll: nil, membership: nil)
    @event = event
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @discussion = discussion
    @poll = poll
    @membership = membership
  end

  def view_template
    render Views::EventMailer::Common::TranslationNotice.new(event: @event, recipient: @recipient)
    render Views::EventMailer::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll,
      with_title: true
    )
    render Views::EventMailer::Poll::Stance.new(
      stance: @event.eventable,
      recipient: @recipient
    )
    render Views::EventMailer::Common::Footer.new(
      event: @event,
      recipient: @recipient,
      notification: @notification,
      discussion: @discussion,
      poll: @poll,
      membership: @membership,
      event_key: @event_key
    )
  end
end
