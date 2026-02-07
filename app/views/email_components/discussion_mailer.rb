# frozen_string_literal: true

class Views::EmailComponents::DiscussionMailer < Views::Base
  include EmailHelper

  def initialize(event:, recipient:, event_key:, notification: nil, discussion: nil, poll: nil, membership: nil)
    @event = event
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @discussion = discussion || @event.eventable.discussion
    @poll = poll
    @membership = membership
  end

  def view_template
    render Views::EmailComponents::Common::TranslationNotice.new(event: @event)
    render Views::EmailComponents::Group::CoverAndLogo.new(group: @discussion.group)
    render Views::EmailComponents::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::EmailComponents::Common::Title.new(eventable: @discussion)
    render Views::EmailComponents::Common::Tags.new(eventable: @discussion)
    render Views::EmailComponents::Common::Body.new(eventable: @event.eventable)
    render Views::EmailComponents::Discussion::CurrentPolls.new(
      discussion: @discussion,
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
