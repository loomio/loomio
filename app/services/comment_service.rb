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
    comment.update(discarded_at: Time.now, discarded_by: actor.id)
    comment.discussion.update_sequence_info!
    MessageChannelService.publish_models([comment.created_event], group_id: comment.group_id)
    comment.created_event
  end

  def self.undiscard(comment:, actor:)
    actor.ability.authorize!(:undiscard, comment)
    comment.update(discarded_at: nil, discarded_by: nil)
    comment.discussion.update_sequence_info!
    MessageChannelService.publish_models([comment.created_event], group_id: comment.group_id)
    comment.created_event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    comment_id = comment.id
    discussion_id = comment.discussion.id
    comment.destroy

    Comment.where(parent_id: comment_id).update_all(parent_id: nil)
    RepairThreadWorker.perform_async(discussion_id)
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
