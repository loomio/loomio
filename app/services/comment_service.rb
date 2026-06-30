class CommentService
  def self.create(comment:, actor:)
    comment.author = actor
    actor.ability.authorize! :create, comment
    comment.save!
    comment.update_pg_search_document
    Sentry.metrics.count("comment.create", attributes: { parent_type: comment.parent_type })
    Events::NewComment.publish!(comment)
  end

  def self.discard(comment:, actor:)
    actor.ability.authorize!(:discard, comment)
    Sentry.metrics.count("comment.discard")
    ActiveRecord::Base.transaction do
      comment.update(discarded_at: Time.now, discarded_by: actor.id)
      comment.created_event.update(pinned: false)
    end
    comment.topic.update_sequence_info!
    ReindexCommentWorker.perform_later(comment.id)
    comment.created_event
  end

  def self.undiscard(comment:, actor:)
    actor.ability.authorize!(:undiscard, comment)
    ActiveRecord::Base.transaction do
      comment.update(discarded_at: nil, discarded_by: nil)
      comment.created_event.update(user_id: comment.user_id)
    end
    ReindexCommentWorker.perform_later(comment.id)
    comment.created_event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    Sentry.metrics.count("comment.destroy")
    topic_id = comment.topic.id
    Comment.where(parent_type: 'Comment', parent_id: comment.id)
           .update_all(parent_type: comment.parent_type, parent_id: comment.parent_id)
    comment.destroy
    RepairTopicWorker.perform_later(topic_id)
  end

  def self.update(comment:, params:, actor:)
    actor.ability.authorize! :update, comment
    comment.edited_at = Time.zone.now

    comment.assign_attributes_and_files(params)
    unless comment.valid?
      Sentry.metrics.count("comment.update_failed", attributes: { columns: comment.errors.attribute_names.join(',') })
      return false
    end
    comment.save!
    comment.update_versions_count
    Sentry.metrics.count("comment.update")
    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
