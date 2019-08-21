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
    comment.delay(priority: 1).destroy
    EventBus.broadcast('comment_destroy', comment)
  end

  def self.update(comment:, params:, actor:)
    comment.edited_at = Time.zone.now
    comment.assign_attributes(params.slice(:body, :body_format, :document_ids))
    comment.files.attach(params[:files])
    comment.image_files.attach(params[:image_files])

    return false unless comment.valid?
    actor.ability.authorize! :update, comment
    comment.save!

    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
