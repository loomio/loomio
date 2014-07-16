class DiscussionService
  def self.unlike_comment(user, comment)
    comment.unlike(user)
  end

  def self.like_comment(user, comment)
    user.ability.authorize!(:like, comment)
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
    comment.discussion.update_attribute(:last_comment_at, comment.created_at)
    event = Events::NewComment.publish!(comment)
    event
  end

  def self.delete_comment(comment: comment, actor: actor)
    actor.ability.authorize!(:destroy, comment)
    comment.destroy
  end

  def self.start_discussion(discussion)
    user = discussion.author
    discussion.inherit_group_privacy!

    return false unless discussion.save

    user.ability.authorize! :create, discussion

    user.update_attributes(uses_markdown: discussion.uses_markdown)
    Events::NewDiscussion.publish!(discussion)
  end

  def self.edit_discussion(user, discussion_params, discussion)
    user.ability.authorize! :update, discussion

    discussion.private = discussion_params[:private]
    discussion.title = discussion_params[:title]
    discussion.description = discussion_params[:description]
    discussion.uses_markdown = discussion_params[:uses_markdown]

    if user.ability.can? :update, discussion.group
      discussion.iframe_src = discussion_params[:iframe_src]
    end

    if discussion.valid?
      if discussion.title_changed?
        Events::DiscussionTitleEdited.publish!(discussion, user)
      end

      if discussion.description_changed?
        Events::DiscussionDescriptionEdited.publish!(discussion, user)
      end
      user.update_attributes(uses_markdown: discussion.uses_markdown)
      discussion.save
    else
      false
    end
  end
end
