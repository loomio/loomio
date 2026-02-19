class CommentService

  def self.create(comment:, actor:)
    actor.ability.authorize! :create, comment
    comment.author = actor
    return false unless comment.valid?
    comment.save!
    EventBus.broadcast('comment_create', comment, actor)
    event = Events::NewComment.publish!(comment)
    comment.update_pg_search_document
    event
  end

  def self.discard(comment:, actor:)
    actor.ability.authorize!(:discard, comment)
    ActiveRecord::Base.transaction do
      comment.update(discarded_at: Time.now, discarded_by: actor.id)
      comment.created_event.update(pinned: false)
    end
    comment.topic&.update_sequence_info!
    comment.created_event
  end

  def self.undiscard(comment:, actor:)
    actor.ability.authorize!(:undiscard, comment)
    ActiveRecord::Base.transaction do
      comment.update(discarded_at: nil, discarded_by: nil)
      comment.created_event.update(user_id: comment.user_id)
    end
    comment.created_event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    comment_id = comment.id
    topic = comment.topic

    comment.destroy
    RepairThreadWorker.perform_async(topic.id) if topic
  end

  def self.update(comment:, params:, actor:)
    actor.ability.authorize! :update, comment
    comment.edited_at = Time.zone.now

    comment.assign_attributes_and_files(params)
    return false unless comment.valid?
    comment.save!
    comment.update_versions_count

    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
