class Caches::DiscussionEvent < Caches::Base
  private

  def resource_class
    Event
  end

  def relation
    :eventable
  end

  def default_values_for(discussion)
    [discussion.created_event]
  end

  def collection_from(parents)
    super.where(kind: ['new_discussion', 'discussion_forked'])
  end
end
