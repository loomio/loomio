class DiscussionHeadline
  attr_accessor :discussion
  attr_accessor :time_frame

  def initialize(discussion, time_frame)
    @discussion = discussion
    @time_frame = time_frame
  end

  def new_discussion?
    is_new?(discussion.created_at)
  end

  private

  def is_new?(time)
    (time >= time_frame.begin) && (time <= time_frame.end)
  end
end
