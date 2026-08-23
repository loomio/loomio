class TopicItemService
  def self.move_comments(topic:, actor:, params:)
    ids = Array(params[:selected_topic_item_ids]).compact
    source_topic = TopicItem.find(ids.first).topic

    actor.ability.authorize! :move_comments, source_topic
    actor.ability.authorize! :move_comments, topic
    MoveCommentsWorker.perform_later(ids, source_topic.id, topic.id, actor.id)
  end
end
