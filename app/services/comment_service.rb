class CommentService
  def self.unlike(comment:, actor:)
    return false unless comment.likers.include? actor
    actor.ability.authorize!(:unlike, comment)

    comment_vote = CommentVote.find_by(comment_id: comment.id, user_id: actor.id)
    comment_vote.destroy

    EventBus.broadcast('comment_unlike', comment_vote)
  end

  def self.like(comment:, actor:)
    actor.ability.authorize!(:like, comment)

    comment_vote = CommentVote.find_or_create_by(comment_id: comment.id, user_id: actor.id)

    EventBus.broadcast('comment_like', comment_vote)
    Events::CommentLiked.publish!(comment_vote)
  end

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
    comment.comment_votes.destroy_all
    comment.destroy
    EventBus.broadcast('comment_destroy', comment)
  end

  def self.update(comment:, params:, actor:)
    comment.edited_at = Time.zone.now
    comment.body = params[:body]

    return false unless comment.valid?
    actor.ability.authorize! :update, comment
    comment.save!
    comment.attachments.where('id NOT IN (?)', params[:attachment_ids]).destroy_all

    EventBus.broadcast('comment_update', comment, actor)
  end
end
