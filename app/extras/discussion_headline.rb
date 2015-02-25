class DiscussionHeadline
  include Routing
  attr_accessor :discussion
  attr_accessor :time_frame

  def initialize(discussion, time_frame)
    @discussion = discussion
    @time_frame = time_frame
  end

  def discussion_synopsis
    if new_discussion?
      case participants.size
      when 1
        "#{participants.first.name} started a discussion: #{linked_discussion_title(discussion)}"
      when 2
        "#{participants.first.name} and #{participants.second.name} started discussing: #{linked_discussion_title(discussion)}"
      else
        "#{participants.first.name} and #{participants.size - 1} others started discussing: #{linked_discussion_title(discussion)}"
      end
    else
      case participants.size
      when 0
        ''
      when 1
        "#{participants.first.name} discussed: #{linked_discussion_title(discussion)}"
      when 2
        "#{participants.first.name} and #{participants.second.name} discussed: #{linked_discussion_title(discussion)}"
      else
        "#{participants.first.name} and #{participants.size - 1} others discussed: #{linked_discussion_title(discussion)}"
      end
    end
  end

  def motion_synopsis
    if new_motion?
      motion = discussion.current_motion
      "#{motion.author_name} proposed: #{motion.title}"
    elsif ongoing_motion?
      motion = discussion.current_motion
      case voters.size
      when 0
        ""
      when 1
        "#{voters.first.name} voted on: #{motion.title}"
      when 2
        "#{voters.first.name} and #{voters.second.name} voted on: #{motion.title}"
      else
        "#{voters.first.name} and #{voters.size - 1} others voted on: #{motion.title}"
      end
    elsif motion_closed?
      motion = discussion.most_recent_motion
      "#{motion.title} closed with #{motion.total_votes_count} participants"
    end
  end

  def render
    if motion_synopsis.present?
      "#{discussion_synopsis} and #{motion_synopsis}"
    else
      discussion_synopsis
    end
  end

  def linked_discussion_title(discussion)
    ActionController::Base.helpers.link_to(discussion.title, Routing.discussion_url(discussion)).html_safe
  end

  def new_motion?
    discussion.current_motion && is_new?(discussion.current_motion.created_at)
  end

  def ongoing_motion?
    discussion.current_motion && !is_new?(discussion.current_motion.created_at)
  end

  def motion_closed?
    (motion = discussion.most_recent_motion) && is_new?(motion.closed_at)
  end

  def new_discussion?
    is_new?(discussion.created_at)
  end

  def participants
    participants = []
    participants << @discussion.author if new_discussion?
    participants += @discussion.comments.where(created_at: time_frame).order(:created_at).map(&:author)
    participants.uniq
  end

  def voters
    discussion.current_motion.votes.where(created_at: time_frame).order(:created_at).map(&:author).uniq
  end

  private

  def is_new?(time)
    (time >= time_frame.begin) && (time <= time_frame.end)
  end
end
