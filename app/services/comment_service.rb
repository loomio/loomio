class CommentService
  def self.unlike(comment:, actor:)
    return false unless comment.likers.include? actor
    actor.ability.authorize!(:like, comment)
    comment_vote = CommentVote.where(user_id: actor.id, comment_id: comment.id).first
    comment.unlike(actor)
    Memos::CommentUnliked.publish!(comment_vote)
  end

  def self.like(comment:, actor:)
    actor.ability.authorize!(:like, comment)
    comment_vote = comment.like(actor)
    DiscussionReader.for(discussion: comment.discussion, user: actor).follow!
    Events::CommentLiked.publish!(comment_vote)
  end

  def self.create(comment:, actor:, mark_as_read: true)
    comment.author = actor
    return false unless comment.valid?
    actor.ability.authorize! :create, comment
    comment.attachment_ids = [comment.attachment_ids, comment.new_attachment_ids].compact.flatten
    comment.save!
    comment.discussion.update_attribute(:last_comment_at, comment.created_at)
    event = Events::NewComment.publish!(comment)
    if mark_as_read
      DiscussionReader.for(user: actor, discussion: comment.discussion).viewed!(comment.created_at)
    end
    event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    comment.destroy
    Memos::CommentDestroyed.publish!(comment)
  end

  def self.update(comment:, params:, actor:)
    comment.edited_at = Time.zone.now
    comment.body = params[:body]
    return false unless comment.valid?
    actor.ability.authorize! :create, comment
    comment.save!
    Memos::CommentUpdated.publish!(comment)
    true
  end
end
