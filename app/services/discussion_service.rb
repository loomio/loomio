class DiscussionService
  def self.unlike_comment(user, comment)
    comment.unlike(user)
  end

  def self.like_comment(user, comment)
    user.ability.authorize!(:like_comments, comment.discussion)
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

  def self.start_discussion(discussion)
    user = discussion.author
    discussion.inherit_group_privacy! if discussion.private.nil?

    return false unless discussion.save

    user.ability.authorize! :create, discussion

    user.update_attributes(uses_markdown: discussion.uses_markdown)
    Events::NewDiscussion.publish!(discussion)
  end

  def self.edit_discussion(user, discussion_params, discussion)
    user.ability.authorize! :update, discussion

    title_changed = true if discussion_params[:title] != discussion.title
    discussion.private = discussion_params[:private]
    discussion.title = discussion_params[:title]
    discussion.description = discussion_params[:description]
    discussion.uses_markdown = discussion_params[:uses_markdown]

    return false unless discussion.save

    user.update_attributes(uses_markdown: discussion.uses_markdown)
    discussion.set_last_non_comment_activity_at if title_changed
  end

end
