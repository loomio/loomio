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
    author.update_attribute(:uses_markdown, comment.uses_markdown)
    comment.discussion.as_read_by(author).viewed!
    event
  end

  def self.start_discussion(discussion)
    user = discussion.author
    user.ability.authorize! :create, discussion

    return false unless discussion.save

    user.update_attribute(:uses_markdown, discussion.uses_markdown)
    Events::NewDiscussion.publish!(discussion)
  end

end
