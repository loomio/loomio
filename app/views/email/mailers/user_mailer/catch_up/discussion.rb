# frozen_string_literal: true

class Views::Email::Mailers::UserMailer::CatchUp::Discussion < Views::Email::Base
  include PrettyUrlHelper

  THREAD_ITEM_KINDS = %w[new_comment new_vote stance_created discussion_closed discussion_edited poll_edited].freeze

  THREAD_COMPONENTS = {
    'new_comment' => Views::Email::Thread::NewComment,
    'stance_created' => Views::Email::Thread::StanceCreated,
    'new_vote' => Views::Email::Thread::StanceCreated,
    'discussion_closed' => Views::Email::Thread::DiscussionClosed,
    'discussion_edited' => Views::Email::Thread::DiscussionEdited,
    'poll_edited' => Views::Email::Thread::PollEdited
  }.freeze

  def initialize(discussion:, recipient:, time_start:, cache:, utm_hash:)
    @discussion = discussion
    @recipient = recipient
    @time_start = time_start
    @cache = cache
    @utm_hash = utm_hash
  end

  def view_template
    div(class: "light-discussion", id: @discussion.key) do
      h2 { link_to plain_text(@discussion, :title), discussion_url(@discussion) }

      if @discussion.created_at >= @time_start
        p { em { plain "by #{@discussion.author.name}" } }
        div(class: "description") { raw formatted_text(@discussion, :description) }
      end

      @discussion.polls.active_or_closed_after(@time_start).each do |poll|
        render Views::Email::Common::Title.new(eventable: poll)
        render Views::Email::Common::Tags.new(eventable: poll)
        render Views::Email::Poll::Summary.new(poll: poll, recipient: @recipient)
        render Views::Email::Poll::Vote.new(poll: poll, recipient: @recipient)
        render Views::Email::Poll::ResultsPanel.new(poll: poll, current_user: @recipient)
      end

      render_activity_feed

      p { link_to t(:"email.reply_to_this_discussion"), discussion_url(@discussion, @utm_hash) }
    end
  end

  private

  def render_activity_feed
    reader = @cache.fetch(:discussion_readers_by_discussion_id, @discussion.id) ||
      DiscussionReader.for(user: @recipient, discussion: @discussion)
    since = [reader.last_read_at, @time_start].compact.max

    div(class: "activity-feed") do
      @discussion.items.where('created_at > ?', since).order('created_at').each do |item|
        next unless THREAD_ITEM_KINDS.include?(item.kind)

        component_class = THREAD_COMPONENTS[item.kind]
        next unless component_class

        render component_class.new(item: item, recipient: @recipient)
      end
    end
  end
end
