# frozen_string_literal: true

class Views::EmailComponents::StanceMailer < Views::Base
  include EmailHelper

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
    render Views::EmailComponents::Common::TranslationNotice.new(event: @event)
    render Views::EmailComponents::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll,
      with_title: true
    )
    render Views::EmailComponents::Poll::Stance.new(
      stance: @event.eventable,
      recipient: @recipient
    )
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
