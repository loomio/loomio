# frozen_string_literal: true

class Views::DeliveryMailer::Poll < Views::DeliveryMailer::Layout

  def initialize(topic_item:, recipient:, event_key:, poll:, notification: nil, discussion: nil, membership: nil)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @poll = poll
    @notification = notification
    @discussion = discussion
    @membership = membership
  end

  def view_template
    render Views::DeliveryMailer::Common::TranslationNotice.new(topic_item: @topic_item, recipient: @recipient)
    render Views::DeliveryMailer::Group::CoverAndLogo.new(group: @topic_item.itemable.poll.group)
    render Views::DeliveryMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::DeliveryMailer::Poll::ShareOutcome.new(topic_item: @topic_item, recipient: @recipient)
    render Views::DeliveryMailer::Common::Title.new(itemable: @poll, recipient: @recipient)
    render Views::DeliveryMailer::Common::Tags.new(itemable: @poll)
    render Views::DeliveryMailer::Poll::Summary.new(poll: @poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::VotingPeriod.new(poll: @poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::Vote.new(poll: @poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::Rules.new(poll: @poll)
    render Views::DeliveryMailer::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)

    if %w[poll_announced poll_created poll_reminder].include?(@topic_item.kind) &&
       discussion = @topic_item.itemable.topic.discussion
      hr
      render Views::DeliveryMailer::Common::Title.new(itemable: discussion, recipient: @recipient)
      render Views::DeliveryMailer::Common::Body.new(itemable: discussion, recipient: @recipient)
    else
      render Views::DeliveryMailer::Poll::Responses.new(topic_item: @topic_item, recipient: @recipient)
    end

    render Views::DeliveryMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end
end
