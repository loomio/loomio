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

  def self.move_comments(discussion:, actor:, params:)
    ids = Array(params[:forked_event_ids]).compact
    source_topic = Event.find(ids.first).topic
    source = source_topic&.topicable

    actor.ability.authorize! :move_comments, source
    actor.ability.authorize! :move_comments, discussion
    MoveCommentsWorker.perform_async(ids, source.id, discussion.id)
  end

end
