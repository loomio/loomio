class EventService
  def self.remove_from_thread(event:, actor:)
    discussion = event.discussion
    raise CanCan::AccessDenied.new unless event.kind == 'discussion_edited'
    actor.ability.authorize! :remove_events, discussion

    event.update(topic_id: nil)
    discussion.update_sequence_info!
    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)

    EventBus.broadcast('event_remove_from_thread', event)
    event
  end

  def self.move_comments(topic:, actor:, params:)
    ids = Array(params[:forked_event_ids]).compact
    source_topic = Event.find(ids.first).topic

    actor.ability.authorize! :move_comments, source_topic
    actor.ability.authorize! :move_comments, topic
    MoveCommentsWorker.perform_async(ids, source_topic.id, topic.id)
  end

end
