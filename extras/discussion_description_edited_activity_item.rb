class DiscussionDescriptionEditedActivityItem
  attr_reader :group, :actor, :time

  def initialize(event, discussion)
    @group, @actor, @time = discussion.group, event.user, event.created_at
  end

  def icon
    'discussion-icon'
  end

  def position
    nil
  end

  def header
    'changed the discussion description'
  end

  def body
    ""
  end

  def version_title(event, discussion)
    discussion.version_at(event.created_at).title
  end
end