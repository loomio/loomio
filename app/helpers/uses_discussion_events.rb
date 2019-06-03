module UsesDiscussionEvents
  private

  def default_scope
    super.merge(discussion_event_cache: Caches::DiscussionEvent.new(
      parents: resources_to_serialize.map(&:discussion)
    ))
  end
end
