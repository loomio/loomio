class ActivityItems::NewDiscussion
  attr_reader :discussion

  def initialize(discussion)
    @discussion = discussion
  end

  def icon
    'discussion-icon'
  end

  def group
    discussion.group
  end

  def actor
    discussion.user
  end

  def header
    "created the discussion: "
  end

  def body
    " \"#{discussion.version_at(discussion.created_at).title}\""
  end

  def time
    discussion.created_at
  end
end