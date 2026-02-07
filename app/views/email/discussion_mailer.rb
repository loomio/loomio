# frozen_string_literal: true

class Views::Email::DiscussionMailer < Views::Email::EventLayout

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
    render Views::Email::Common::TranslationNotice.new(event: @event)
    render Views::Email::Group::CoverAndLogo.new(group: @discussion.group)
    render Views::Email::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::Email::Common::Title.new(eventable: @discussion)
    render Views::Email::Common::Tags.new(eventable: @discussion)
    render Views::Email::Common::Body.new(eventable: @event.eventable)
    render Views::Email::Discussion::CurrentPolls.new(
      discussion: @discussion,
      recipient: @recipient
    )
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
