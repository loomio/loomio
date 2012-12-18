class DiscussionTitleEditedActivityItem
  attr_reader :group, :actor, :body, :time

  def initialize(event, discussion)
    @group, @actor, @body, @time = discussion.group, event.user, " \"#{version_title(event, discussion)}\"",
      event.created_at
  end

  def icon
    'loomio-icon'
  end

  def position
    nil
  end

  def header
    'changed the discussion title:'
  end

  def version_title(event, discussion)
    discussion.version_at(event.created_at).title
  end
end