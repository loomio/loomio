# frozen_string_literal: true

class Views::EventMailer::Poll < Views::EventMailer::EventLayout

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
    render Views::EventMailer::Common::TranslationNotice.new(event: @event, recipient: @recipient)
    render Views::EventMailer::Group::CoverAndLogo.new(group: @event.eventable.poll.group)
    render Views::EventMailer::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::EventMailer::Poll::ShareOutcome.new(event: @event, recipient: @recipient)
    render Views::EventMailer::Common::Title.new(eventable: @poll, recipient: @recipient)
    render Views::EventMailer::Common::Tags.new(eventable: @poll)
    render Views::EventMailer::Poll::Summary.new(poll: @poll, recipient: @recipient)
    render Views::EventMailer::Poll::VotingPeriod.new(poll: @poll, recipient: @recipient)
    render Views::EventMailer::Poll::Vote.new(poll: @poll, recipient: @recipient)
    render Views::EventMailer::Poll::Rules.new(poll: @poll)
    render Views::EventMailer::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)

    if %w[poll_announced poll_created poll_reminder].include?(@event.kind) && @event.eventable.discussion
      hr
      render Views::EventMailer::Common::Title.new(eventable: @event.eventable.discussion, recipient: @recipient)
      render Views::EventMailer::Common::Body.new(eventable: @event.eventable.discussion, recipient: @recipient)
    else
      render Views::EventMailer::Poll::Responses.new(event: @event, recipient: @recipient)
    end

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
