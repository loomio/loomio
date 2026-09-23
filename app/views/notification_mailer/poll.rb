# frozen_string_literal: true

class Views::NotificationMailer::Poll < Views::NotificationMailer::Layout

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
    render Views::NotificationMailer::Common::TranslationNotice.new(topic_item: @topic_item, recipient: @recipient)
    render Views::NotificationMailer::Group::CoverAndLogo.new(group: @topic_item.itemable.poll.group)
    render Views::NotificationMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      poll: @poll
    )
    render Views::NotificationMailer::Poll::ShareOutcome.new(topic_item: @topic_item, recipient: @recipient)
    render Views::NotificationMailer::Common::Title.new(itemable: @poll, recipient: @recipient)
    render Views::NotificationMailer::Common::Tags.new(itemable: @poll)
    render Views::NotificationMailer::Poll::Summary.new(poll: @poll, recipient: @recipient)
    render Views::NotificationMailer::Poll::VotingPeriod.new(poll: @poll, recipient: @recipient)
    render Views::NotificationMailer::Poll::Vote.new(poll: @poll, recipient: @recipient)
    render Views::NotificationMailer::Poll::Rules.new(poll: @poll)
    render Views::NotificationMailer::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)

    if %w[poll_announced poll_created poll_reminder].include?(@topic_item.kind) &&
       discussion = @topic_item.itemable.topic.discussion
      hr
      render Views::NotificationMailer::Common::Title.new(itemable: discussion, recipient: @recipient)
      render Views::NotificationMailer::Common::Body.new(itemable: discussion, recipient: @recipient)
    else
      render Views::NotificationMailer::Poll::Responses.new(topic_item: @topic_item, recipient: @recipient)
    end

    render Views::NotificationMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end
end
