# frozen_string_literal: true

class Views::Email::PollMailer < Views::Email::EventLayout

  def initialize(event:, recipient:, event_key:, poll:, notification: nil, discussion: nil, membership: nil)
    @event = event
    @recipient = recipient
    @event_key = event_key
    @poll = poll
    @notification = notification
    @discussion = discussion
    @membership = membership
  end

  def view_template
    render Views::Email::Common::TranslationNotice.new(event: @event, recipient: @recipient)
    render Views::Email::Group::CoverAndLogo.new(group: @event.eventable.poll.group)
    render Views::Email::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::Email::Poll::ShareOutcome.new(event: @event, recipient: @recipient)
    render Views::Email::Common::Title.new(eventable: @poll, recipient: @recipient)
    render Views::Email::Common::Tags.new(eventable: @poll)
    render Views::Email::Poll::Summary.new(poll: @poll, recipient: @recipient)
    render Views::Email::Poll::Vote.new(poll: @poll, recipient: @recipient)
    render Views::Email::Poll::Rules.new(poll: @poll)
    render Views::Email::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)

    if %w[poll_announced poll_created poll_reminder].include?(@event.kind) && @event.eventable.discussion
      hr
      render Views::Email::Common::Title.new(eventable: @event.eventable.discussion, recipient: @recipient)
      render Views::Email::Common::Body.new(eventable: @event.eventable.discussion, recipient: @recipient)
    else
      render Views::Email::Poll::Responses.new(event: @event, recipient: @recipient)
    end

    render Views::Email::Common::Footer.new(
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
