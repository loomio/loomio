class TopicItemService
  def self.move_comments(topic:, actor:, params:)
    ids = Array(params[:selected_topic_item_ids]).compact
    source_topic = TopicItem.find(ids.first).topic

    actor.ability.authorize! :move_comments, source_topic
    actor.ability.authorize! :move_comments, topic

    if source_topic.topicable_type == 'Poll' && ids == [source_topic.topicable.created_topic_item.id]
      # The add-to-discussion flow opens the moved poll as soon as this request completes.
      # Complete the move first so that route resolves to the destination discussion.
      MoveCommentsWorker.perform_now(ids, source_topic.id, topic.id, actor.id)
    else
      MoveCommentsWorker.perform_later(ids, source_topic.id, topic.id, actor.id)
    end
  end
end
