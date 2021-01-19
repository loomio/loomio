class CommentService

  def self.create(comment:, actor:)
    actor.ability.authorize! :create, comment
    comment.author = actor
    return false unless comment.valid?
    comment.save!
    EventBus.broadcast('comment_create', comment, actor)
    Events::CommentRepliedTo.publish!(comment) if comment.parent
    Events::NewComment.publish!(comment)
  end

  def self.discard(comment:, actor:)
    actor.ability.authorize!(:discard, comment)
    ActiveRecord::Base.transaction do
      comment.update(discarded_at: Time.now, discarded_by: actor.id)
      comment.created_event.update(user_id: nil, pinned: false)
    end
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
    discussion_id = comment.discussion.id
    comment.destroy

    Comment.where(parent_id: comment_id).update_all(parent_id: nil)
    EventService.delay.repair_thread(discussion_id)
  end

  def self.update(comment:, params:, actor:)
    actor.ability.authorize! :update, comment
    comment.edited_at = Time.zone.now

    HasRichText.assign_attributes_and_update_files(comment, params)
    return false unless comment.valid?
    comment.save!
    comment.update_versions_count

    EventBus.broadcast('comment_update', comment, actor)
    Events::CommentEdited.publish!(comment, actor)
  end
end
