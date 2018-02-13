class CommentService

  def self.create(comment:, actor:)
    actor.ability.authorize! :create, comment
    comment.author = actor
    return false unless comment.valid?

    comment.save!
    EventBus.broadcast('comment_create', comment, actor)
    Events::NewComment.publish!(comment)
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    comment.destroy
    EventBus.broadcast('comment_destroy', comment)
  end

  def self.update(comment:, params:, actor:)
    comment.edited_at = Time.zone.now
    comment.assign_attributes(params.slice(:body, :document_ids))

    return false unless comment.valid?
    actor.ability.authorize! :update, comment
    comment.save!

    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
