class DiscussionService
  def self.unlike_comment(user, comment)
    user.ability.authorize!(:like, comment)
    comment.unlike(user)
  end

  def self.like_comment(user, comment)
    user.ability.authorize!(:like, comment)
    comment_vote = comment.like(user)
    DiscussionReader.for(discussion: comment.discussion, user: user).follow!
    Events::CommentLiked.publish!(comment_vote)
  end

  def self.add_comment(user_or_comment, comment = nil)
    if comment.nil?
      comment = user_or_comment
      author = comment.author
    else
      author = user_or_comment
    end

    return false unless comment.valid?

    author.ability.authorize! :add_comment, comment.discussion

    comment.save!

    comment.discussion.update_attribute(:last_comment_at, comment.created_at)

    DiscussionReader.for(user: author, discussion: comment.discussion).viewed!(comment.created_at)

    Events::NewComment.publish!(comment)
  end

  def self.delete_comment(comment: comment, actor: actor)
    actor.ability.authorize!(:destroy, comment)
    comment.destroy
  end

  def self.start_discussion(discussion)
    user = discussion.author
    discussion.inherit_group_privacy!
    return false unless discussion.valid?

    user.ability.authorize! :create, discussion
    discussion.save!
    user.update_attributes(uses_markdown: discussion.uses_markdown)
    Events::NewDiscussion.publish!(discussion)
  end

  def self.edit_discussion(user, params, discussion)
    user.ability.authorize! :update, discussion

    [:private, :title, :description, :uses_markdown].each do |attr|
      discussion.send("#{attr}=", params[attr]) if params.has_key?(attr)
    end

    if user.ability.can? :update, discussion.group
      discussion.iframe_src = params[:iframe_src]
    end

    return false unless discussion.valid?

    discussion.save!
    if discussion.title_changed?
      Events::DiscussionTitleEdited.publish!(discussion, user)
    end

    if discussion.description_changed?
      Events::DiscussionDescriptionEdited.publish!(discussion, user)
    end

    user.update_attributes(uses_markdown: discussion.uses_markdown)
    DiscussionReader.for(discussion: discussion, user: user).follow!
  end
end
