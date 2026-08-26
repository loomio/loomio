# frozen_string_literal: true

class Views::NotificationMailer::Stance < Views::NotificationMailer::Layout

  def initialize(topic_item:, recipient:, event_key:, notification: nil, discussion: nil, poll: nil, membership: nil)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @discussion = discussion
    @poll = poll
    @membership = membership
  end

  def view_template
    render Views::NotificationMailer::Common::TranslationNotice.new(topic_item: @topic_item, recipient: @recipient)
    render Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll,
      with_title: true
    )
    render Views::NotificationMailer::Poll::Stance.new(
      stance: @topic_item.itemable,
      recipient: @recipient
    )
    render Views::NotificationMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end
end
