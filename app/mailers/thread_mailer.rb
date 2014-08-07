class ThreadMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def new_discussion(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'
    send_thread_email_for(@discussion)
  end

  def new_comment(comment, user)
    @user = user
    @comment = comment
    @discussion = comment.discussion
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    send_thread_email_for(@comment)
  end

  def new_vote(vote, user)
    @user = user
    @vote = vote
    @position = @vote.position
    @motion = @vote.motion
    @discussion = @motion.discussion
    send_thread_email_for(@vote)
  end

  def new_motion(motion, user)
    @user = user
    @motion = motion
    @discussion = motion.discussion
    @group = @discussion.group
    send_thread_email_for(@motion)
  end

  def mentioned(user, comment)
    @user = user
    @comment = comment
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    @discussion = comment.discussion
    send_thread_email_for(@comment)
  end

  private

  def send_thread_email_for(object)
    locale = locale_fallback(@user.locale, object.author.locale)
    I18n.with_locale(locale) do
      mail  to: @user.email,
            from: from_user_via_loomio(object.author),
            reply_to: reply_to_address(discussion: @discussion, user: @user),
            subject: thread_subject
    end
  end

  def thread_subject
    @discussion.title
  end
end
