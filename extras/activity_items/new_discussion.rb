class ActivityItems::NewDiscussion
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
    discussion.author
  end

  def header
    "created the discussion: "
  end

  def body
    # " \"#{discussion.title}\""
    " \"#{discussion.version_at(event.created_at).title}\""
  end

  def time
    discussion.created_at
  end
end