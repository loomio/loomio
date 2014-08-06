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
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_discussion.subject", which: @discussion.title)
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
           subject: t("email.mentioned.subject", who: comment.author.name, which: comment.group.name)
    end
  end

  def motion_closing_soon(user, motion)
    @user = user
    @motion = motion
    @group = motion.group
    @rendered_motion_description = render_rich_text(motion.description, false) #later: change false to motion.uses_markdown
    @utm_hash = UTM_EMAIL.merge utm_source: 'motion_closing_soon'
    locale = locale_fallback(user.locale, @motion.author.locale)
    I18n.with_locale(locale) do
      mail to: user.email,
           from: from_user_via_loomio(motion.author),
           reply_to: motion.author_name_and_email,
           subject: "#{t(:"email.proposal_closing_soon.closing_in_24_hours")}: #{motion.name} - #{@group.name}"
    end
  end
end
