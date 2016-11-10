class Events::CommentLiked < Event
  include PrettyUrlHelper

  def self.publish!(comment_vote)
    create(kind: "comment_liked",
           eventable: comment_vote).tap { |e| EventBus.broadcast('comment_liked_event', e) }
  end

  def users_to_notify
    Array((comment.author if notify_author?))
  end

  private

  def notification_url
    polymorphic_url comment
  end

  def notify_author?
    return false unless comment
    user != comment.author &&                               # you didn't like your own comment
    comment.group.memberships.find_by(user: comment.author) # the author is still in the group
  end

  def comment
    @comment ||= eventable&.comment
  end
end
