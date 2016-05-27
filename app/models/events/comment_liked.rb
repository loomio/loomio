class Events::CommentLiked < Event
  after_create :notify_users!

  def self.publish!(comment_vote)
    create(kind: "comment_liked",
           eventable: comment_vote).tap { |e| EventBus.broadcast('comment_liked_event', e) }
  end

  private

  def notify_users!
    unless eventable.user == eventable.comment_user
      notify!(eventable.comment_user)
    end
  end
end
