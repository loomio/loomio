class DiscussionService
  def self.unlike_comment(user, comment)
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

    author.ability.authorize! :add_comment, comment.discussion

    return false unless comment.save
    comment.discussion.update_attribute(:last_comment_at, comment.created_at)

    # Ensure the comment author is following
    # Ensure that mentioned users are following
    # Create mentioned events for mentioned users
    #
    # Email (non mentioned, non author, followers) who are subscribed to emails

    DiscussionReader.for(discussion: comment.discussion, user: author).follow!

    comment.mentioned_group_members.each do |mentioned_user|
      DiscussionReader.for(discussion: comment.discussion,
                           user: mentioned_user).follow!

      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    remaining_followers = (discussion.followers -
                           mentioned_group_members -
                           [author])

    followers_to_email = remaining_followers.select {|u| u.email_preferences.email_followed_threads? }

    followers_to_email.each do |user|
      UserMailer.new_comment(comment: comment, recipient: user)
    end

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

    user.ability.authorize! :create, discussion

    return false unless discussion.save
    user.update_attributes(uses_markdown: discussion.uses_markdown)

    DiscussionReader.for(discussion: discussion, user: user).follow!

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

    if discussion.valid?
      if discussion.title_changed?
        Events::DiscussionTitleEdited.publish!(discussion, user)
      end

      if discussion.description_changed?
        Events::DiscussionDescriptionEdited.publish!(discussion, user)
      end
      user.update_attributes(uses_markdown: discussion.uses_markdown)
      DiscussionReader.for(discussion: discussion, user: user).follow!
      discussion.save
    else
      false
    end
  end
end
