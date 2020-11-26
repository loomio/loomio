class Simple::DiscussionSerializer < DiscussionSerializer
  def include_group?
    false
  end

  def include_active_polls?
    false
  end

  def include_created_event?
    false
  end

  def include_forked_event?
    false
  end
end
