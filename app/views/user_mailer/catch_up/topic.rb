# frozen_string_literal: true

class Views::UserMailer::CatchUp::Topic < Views::ApplicationMailer::Component
  include PrettyUrlHelper

  THREAD_ITEM_KINDS = %w[new_comment stance_created discussion_edited poll_edited].freeze

  THREAD_COMPONENTS = {
    'new_comment' => Views::EventMailer::Thread::NewComment,
    'stance_created' => Views::EventMailer::Thread::StanceCreated,
    'discussion_edited' => Views::EventMailer::Thread::DiscussionEdited,
    'poll_edited' => Views::EventMailer::Thread::PollEdited
  }.freeze

  def initialize(topic:, recipient:, time_start:, cache:, utm_hash:)
    @topic = topic
    @topicable = topic.topicable
    @recipient = recipient
    @time_start = time_start
    @cache = cache
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
      render Views::EventMailer::Common::Title.new(eventable: poll, recipient: @recipient)
      render Views::EventMailer::Common::Tags.new(eventable: poll)
      render Views::EventMailer::Poll::Summary.new(poll: poll, recipient: @recipient)
      render Views::EventMailer::Poll::Vote.new(poll: poll, recipient: @recipient)
      render Views::EventMailer::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
    end
  end

  def render_activity_feed
    reader = @cache.fetch(:topic_readers_by_topic_id, @topic.id) ||
      TopicReader.for(user: @recipient, topic: @topic)
    since = [reader.last_read_at, @time_start].compact.max

    div(class: "activity-feed") do
      @topic.items.where('created_at > ?', since).order('created_at').each do |item|
        next unless THREAD_ITEM_KINDS.include?(item.kind)

        component_class = THREAD_COMPONENTS[item.kind]
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
