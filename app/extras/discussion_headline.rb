class DiscussionHeadline
  attr_accessor :discussion
  attr_accessor :time_frame

  def initialize(discussion, time_frame)
    @discussion = discussion
    @time_frame = time_frame
  end

  def has_motion?
    new_motion? or ongoing_motion? or motion_closed?
  end

  def motion
    if new_motion? or ongoing_motion?
      discussion.current_motion
    elsif motion_closed?
      discussion.most_recent_motion
    end
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

  private

  def is_new?(time)
    (time >= time_frame.begin) && (time <= time_frame.end)
  end
end
