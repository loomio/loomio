class Events::NewDiscussion < Event
  def self.publish!(discussion)
    create(kind: 'new_discussion',
           eventable: discussion).tap { |e| EventBus.broadcast('new_discussion_event', e) }
  end

  def group_key
    eventable.group.key
  end

  def discussion
    eventable
  end
end
