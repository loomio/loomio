class DiscussionService
  def self.unlike_comment(user, comment)
    comment.unlike(user)
  end

  def self.like_comment(user, comment)
    user.ability.can?(:like_comments, comment.discussion)
    comment_vote = comment.like(user)
    Events::CommentLiked.publish!(comment_vote)
  end

  def self.add_comment(user_or_comment, comment = nil)
    if comment.nil?
      comment = user_or_comment
      author = comment.author
    else
      author = user_or_comment
    end

    author.ability.authorize! :add_comment, comment.discussion
    return false unless comment.save

    event = Events::NewComment.publish!(comment)
    comment.discussion.update_attribute(:last_comment_at, comment.created_at)
    event
  end
end
