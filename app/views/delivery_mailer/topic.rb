# frozen_string_literal: true

class Views::DeliveryMailer::Topic < Views::DeliveryMailer::Layout

  def initialize(topic_item:, recipient:, event_key:, notification: nil, topic: nil, membership: nil)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @topic = topic || event_topic
    @topicable = @topic.topicable
    @membership = membership
  end

  def view_template
    render Views::DeliveryMailer::Common::TranslationNotice.new(topic_item: @topic_item, recipient: @recipient) unless @topic_item.itemable.is_a?(Topic)
    render Views::DeliveryMailer::Group::CoverAndLogo.new(group: @topic.group)
    render Views::DeliveryMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      poll: topicable_poll,
      url: tracked_url(@topicable, recipient: @recipient),
      title: title_link_html
    )

    if @topicable.is_a?(Discussion)
      render_discussion_topic
    elsif @topicable.is_a?(Poll)
      render_poll_topic
    end

    render Views::DeliveryMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end

  private

  def event_topic
    return @topic_item.itemable if @topic_item.itemable.is_a?(Topic)
    return @topic_item.topic if @topic_item.topic
    @topic_item.itemable.topic
  end

  def topicable_poll
    @topicable if @topicable.is_a?(Poll)
  end

  def render_discussion_topic
    render Views::DeliveryMailer::Common::Title.new(itemable: @topicable, recipient: @recipient)
    render Views::DeliveryMailer::Common::Tags.new(itemable: @topicable)
    render Views::DeliveryMailer::Common::Body.new(itemable: @topicable, recipient: @recipient)

    active_polls = @topicable.polls.active.order('closing_at asc')

    if active_polls.one?
      poll = active_polls.first

      hr
      render Views::DeliveryMailer::Common::Title.new(itemable: poll, recipient: @recipient)
      render Views::DeliveryMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
      render Views::DeliveryMailer::Poll::VotingPeriod.new(poll: poll, recipient: @recipient)
      render Views::DeliveryMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
      render Views::DeliveryMailer::Poll::Rules.new(poll: poll)
      render Views::DeliveryMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
    else
      render Views::DeliveryMailer::Discussion::CurrentPolls.new(
        discussion: @topicable,
        recipient: @recipient
      )
    end
  end

  def render_poll_topic
    poll = @topic.polls.active.order('closing_at asc').first || @topicable

    render Views::DeliveryMailer::Common::Title.new(itemable: poll, recipient: @recipient)
    render Views::DeliveryMailer::Common::Tags.new(itemable: poll)
    render Views::DeliveryMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::VotingPeriod.new(poll: poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
    render Views::DeliveryMailer::Poll::Rules.new(poll: poll)
    render Views::DeliveryMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
  end

  def title_link_html
    capture do
      a(href: tracked_url(@topicable, recipient: @recipient)) do
        plain TranslationService.plain_text(@topicable, :title, @recipient)
      end
    end
  end
end
