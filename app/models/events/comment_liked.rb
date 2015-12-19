class Events::CommentLiked < Event
  after_create :notify_users!

  def self.publish!(comment_vote)
    create(kind: "comment_liked",
           eventable: comment_vote).tap { |e| EventBus.broadcast('comment_liked_event', e) }
  end

  def comment_vote
    eventable
  end

  def discussion_key
    eventable.comment.discussion.key
  end

  private

  def notify_users!
    unless comment_vote.user == comment_vote.comment_user
      notify!(comment_vote.comment_user)
    end
  end
end
