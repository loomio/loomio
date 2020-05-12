class CommentService

  def self.create(comment:, actor:)
    actor.ability.authorize! :create, comment
    comment.author = actor
    return false unless comment.valid?
    comment.update_attachments!
    comment.save!
    EventBus.broadcast('comment_create', comment, actor)
    Events::NewComment.publish!(comment)
  end

  def self.discard(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)

    comment.update(user_id: nil,
                   body: nil,
                   discarded_at: Time.now,
                   discarded_by: actor.id)

    comment.created_event.update(user_id: nil)
    comment.created_event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)

    comment.destroy

    Comment.where(parent_id: comment.id).update_all(parent_id: nil)
    RearrangeEventsWorker.perform_async(comment.discussion_id)
  end

  def self.update(comment:, params:, actor:)
    actor.ability.authorize! :update, comment
    comment.edited_at = Time.zone.now

    HasRichText.assign_attributes_and_update_files(comment, params)
    return false unless comment.valid?
    comment.update_attachments!
    comment.save!

    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
