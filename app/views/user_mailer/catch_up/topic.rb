# frozen_string_literal: true

class Views::UserMailer::CatchUp::Topic < Views::ApplicationMailer::Component
  include PrettyUrlHelper

  TOPIC_ITEM_KINDS = %w[new_comment stance_created discussion_edited poll_edited].freeze

  TOPIC_ITEM_COMPONENTS = {
    'new_comment' => Views::NotificationMailer::TopicItems::NewComment,
    'stance_created' => Views::NotificationMailer::TopicItems::StanceCreated,
    'discussion_edited' => Views::NotificationMailer::TopicItems::DiscussionEdited,
    'poll_edited' => Views::NotificationMailer::TopicItems::PollEdited
  }.freeze

  def initialize(topic:, recipient:, time_start:, utm_hash:)
    @topic = topic
    @topicable = topic.topicable
    @recipient = recipient
    @time_start = time_start
    @utm_hash = utm_hash
  end

  def view_template
    div(class: "light-discussion", id: @topicable.respond_to?(:key) ? @topicable.key : "topic-#{@topic.id}") do
      render_title
      render_new_content
      render_polls
      render_activity_feed
      p { link_to t(:"email.reply_to_this_discussion"), topicable_url }
    end
  end

  private

  def render_title
    h2 { link_to TranslationService.plain_text(@topicable, :title, @recipient), topicable_url }
  end

  def render_new_content
    return unless @topicable.created_at >= @time_start

    if @topicable.is_a?(Discussion)
      p { em { plain "by #{@topicable.author.name}" } }
      div(class: "description") { raw TranslationService.formatted_text(@topicable, :description, @recipient) }
    elsif @topicable.is_a?(Poll)
      p { em { plain "by #{@topicable.author.name}" } }
    end
  end

  def render_polls
    polls = if @topicable.is_a?(Discussion)
      @topicable.polls.active_or_closed_after(@time_start)
    elsif @topicable.is_a?(Poll)
      [@topicable]
    else
      []
    end

    polls.each do |poll|
      render Views::NotificationMailer::Common::Title.new(itemable: poll, recipient: @recipient)
      render Views::NotificationMailer::Common::Tags.new(itemable: poll)
      render Views::NotificationMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
      render Views::NotificationMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
      render Views::NotificationMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
    end
  end

  def render_activity_feed
    reader = TopicReader.for(user: @recipient, topic: @topic)
    since = [reader.last_read_at, @time_start].compact.max

    div(class: "activity-feed") do
      @topic.items.includes(:notification).where('created_at > ?', since).order('created_at').each do |item|
        next unless TOPIC_ITEM_KINDS.include?(item.kind)

        component_class = TOPIC_ITEM_COMPONENTS[item.kind]
        next unless component_class

        render component_class.new(item: item, recipient: @recipient)
      end
    end
  end

  def topicable_url
    if @topicable.is_a?(Discussion)
      discussion_url(@topicable, @utm_hash)
    elsif @topicable.is_a?(Poll)
      polymorphic_url(@topicable, @utm_hash)
    end
  end
end
