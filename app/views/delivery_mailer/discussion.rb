# frozen_string_literal: true

class Views::DeliveryMailer::Discussion < Views::DeliveryMailer::Layout

  def initialize(topic_item:, recipient:, event_key:, notification: nil, discussion: nil, poll: nil, membership: nil)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @discussion = discussion || @topic_item.itemable.topic.discussion
    @poll = poll
    @membership = membership
  end

  def view_template
    render Views::DeliveryMailer::Common::TranslationNotice.new(topic_item: @topic_item, recipient: @recipient)
    render Views::DeliveryMailer::Group::CoverAndLogo.new(group: @discussion.group)
    render Views::DeliveryMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::DeliveryMailer::Common::Title.new(itemable: @discussion, recipient: @recipient)
    render Views::DeliveryMailer::Common::Tags.new(itemable: @discussion)
    render Views::DeliveryMailer::Common::Body.new(itemable: @topic_item.itemable, recipient: @recipient)
    render Views::DeliveryMailer::Discussion::CurrentPolls.new(
      discussion: @discussion,
      recipient: @recipient
    )
    render Views::DeliveryMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end
end
