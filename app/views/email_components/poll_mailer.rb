# frozen_string_literal: true

class Views::EmailComponents::PollMailer < Views::Base
  include Phlex::Rails::Helpers::T
  include EmailHelper

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
    render Views::EmailComponents::Common::TranslationNotice.new(event: @event)
    render Views::EmailComponents::Group::CoverAndLogo.new(group: @event.eventable.poll.group)
    render Views::EmailComponents::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::EmailComponents::Poll::ShareOutcome.new(event: @event)
    render Views::EmailComponents::Common::Title.new(eventable: @poll)
    render Views::EmailComponents::Common::Tags.new(eventable: @poll)
    render Views::EmailComponents::Poll::Summary.new(poll: @poll, recipient: @recipient)
    render Views::EmailComponents::Poll::Vote.new(poll: @poll, recipient: @recipient)
    render Views::EmailComponents::Poll::Rules.new(poll: @poll)
    render Views::EmailComponents::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)

    if %w[poll_announced poll_created poll_reminder].include?(@event.kind) && @event.eventable.discussion
      hr
      render Views::EmailComponents::Common::Title.new(eventable: @event.eventable.discussion)
      render Views::EmailComponents::Common::Body.new(eventable: @event.eventable.discussion)
    else
      render Views::EmailComponents::Poll::Responses.new(event: @event, recipient: @recipient)
    end

    render Views::EmailComponents::Common::Footer.new(
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
