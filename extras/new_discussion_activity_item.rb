class NewDiscussionActivityItem
  attr_reader :group, :actor, :body, :time

  def initialize(discussion)
    @group, @actor, @header, @body, @time = discussion.group, discussion.user, " \"#{version_title(discussion)}\"",
      discussion.created_at
  end

  def icon
    'discussion-icon'
  end

  def position
    nil
  end

  def header
    "created the discussion: "
  end

  def version_title(discussion)
    discussion.version_at(discussion.created_at).title
  end
end