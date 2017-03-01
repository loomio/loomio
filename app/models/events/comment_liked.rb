class Events::CommentLiked < Event
  include PrettyUrlHelper
  include Events::LiveUpdate
  include Events::NotifyUser

  def self.publish!(comment_vote)
    create(kind: "comment_liked",
           eventable: comment_vote).tap { |e| EventBus.broadcast('comment_liked_event', e) }
  end

  private

  def notification_recipients
    return User.none if !comment ||                # there is no comment
                         user == comment.author || # you liked your own comment
                         !comment.group.memberships.find_by(user: comment.author) # the author has left the group
    User.where(id: comment.author_id)
  end

  def comment
    @comment ||= eventable&.comment
  end
end
