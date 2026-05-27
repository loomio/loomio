# frozen_string_literal: true

class Views::EventMailer::Topic < Views::EventMailer::Layout

  def initialize(event:, recipient:, event_key:, notification: nil, topic: nil, membership: nil)
    @event = event
    @recipient = recipient
    @event_key = event_key
    @notification = notification
    @topic = topic || event_topic
    @topicable = @topic.topicable
    @membership = membership
  end

  def view_template
    render Views::EventMailer::Common::TranslationNotice.new(event: @event, recipient: @recipient) unless @event.eventable.is_a?(Topic)
    render Views::EventMailer::Group::CoverAndLogo.new(group: @topic.group)
    render Views::EventMailer::Common::Notification.new(
      event: @event,
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

    render Views::EventMailer::Common::Footer.new(
      event: @event,
      recipient: @recipient,
      notification: @notification,
      membership: @membership,
      event_key: @event_key
    )
  end

  private

  def event_topic
    return @event.eventable if @event.eventable.is_a?(Topic)
    return @event.topic if @event.topic
    @event.eventable.topic
  end

  def topicable_poll
    @topicable if @topicable.is_a?(Poll)
  end

  def render_discussion_topic
    render Views::EventMailer::Common::Title.new(eventable: @topicable, recipient: @recipient)
    render Views::EventMailer::Common::Tags.new(eventable: @topicable)
    render Views::EventMailer::Common::Body.new(eventable: @topicable, recipient: @recipient)

    active_polls = @topicable.polls.active.order('closing_at asc')

    if active_polls.one?
      poll = active_polls.first

      hr
      render Views::EventMailer::Common::Title.new(eventable: poll, recipient: @recipient)
      render Views::EventMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
      render Views::EventMailer::Poll::VotingPeriod.new(poll: poll, recipient: @recipient)
      render Views::EventMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
      render Views::EventMailer::Poll::Rules.new(poll: poll)
      render Views::EventMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
    else
      render Views::EventMailer::Discussion::CurrentPolls.new(
        discussion: @topicable,
        recipient: @recipient
      )
    end
  end

  def render_poll_topic
    poll = @topic.polls.active.order('closing_at asc').first || @topicable

    render Views::EventMailer::Common::Title.new(eventable: poll, recipient: @recipient)
    render Views::EventMailer::Common::Tags.new(eventable: poll)
    render Views::EventMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
    render Views::EventMailer::Poll::VotingPeriod.new(poll: poll, recipient: @recipient)
    render Views::EventMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
    render Views::EventMailer::Poll::Rules.new(poll: poll)
    render Views::EventMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
  end

  def title_link_html
    capture do
      a(href: tracked_url(@topicable, recipient: @recipient)) do
        plain TranslationService.plain_text(@topicable, :title, @recipient)
      end
    end
  end
end
