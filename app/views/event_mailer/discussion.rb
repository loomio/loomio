# frozen_string_literal: true

class Views::EventMailer::Discussion < Views::EventMailer::EventLayout

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
    render Views::EventMailer::Common::TranslationNotice.new(event: @event, recipient: @recipient)
    render Views::EventMailer::Group::CoverAndLogo.new(group: @discussion.group)
    render Views::EventMailer::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::EventMailer::Common::Title.new(eventable: @discussion, recipient: @recipient)
    render Views::EventMailer::Common::Tags.new(eventable: @discussion)
    render Views::EventMailer::Common::Body.new(eventable: @event.eventable, recipient: @recipient)
    render Views::EventMailer::Discussion::CurrentPolls.new(
      discussion: @discussion,
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
