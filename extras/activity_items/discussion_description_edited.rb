class ActivityItems::DiscussionDescriptionEdited
  attr_reader :event, :discussion

  def initialize(event, discussion)
    @event, @discussion = event, discussion
  end

  def icon
    'discussion-icon'
  end

  def group
    discussion.group
  end

  def actor
    event.user
  end

  def header
    'changed the discussion description'
  end

  def body
    ""
  end

  def time
    event.created_at
  end
end