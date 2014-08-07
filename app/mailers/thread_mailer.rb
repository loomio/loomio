class ThreadMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def new_discussion(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    locale = locale_fallback(user.locale, discussion.author.locale)
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'

    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(discussion.author),
            reply_to: reply_to_address(discussion: discussion, user: user),
            subject: thread_subject
    end
  end

  def new_comment(comment, user)
    @comment = comment
    @discussion = comment.discussion
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    locale = locale_fallback(user.locale, comment.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(comment.author),
            reply_to: reply_to_address(discussion: @discussion, user: user),
            subject: thread_subject
    end
  end

  def new_vote(vote, user)
    @vote = vote
    @position = vote.position
    @motion = @vote.motion
    @discussion = @motion.discussion
    locale = locale_fallback(user.locale, vote.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(vote.author),
            reply_to: reply_to_address(discussion: @discussion, user: user),
            subject: thread_subject
    end
  end

  def mentioned(user, comment)
    @user = user
    @comment = comment
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    @discussion = comment.discussion
    locale = locale_fallback(user.locale, comment.author.locale)
    I18n.with_locale(locale) do
      mail to: @user.email,
           from: from_user_via_loomio(comment.author),
           reply_to: reply_to_address(discussion: @discussion, user: @user),
           subject: thread_subject
    end
  end

  private

  def thread_subject
    @discussion.title
  end
end
