class EventService
  def self.move_comments(topic:, actor:, params:)
    ids = Array(params[:forked_event_ids]).compact
    source_topic = Event.find(ids.first).topic

    actor.ability.authorize! :move_comments, source_topic
    actor.ability.authorize! :move_comments, topic
    MoveCommentsWorker.perform_async(ids, source_topic.id, topic.id)
  end

end
