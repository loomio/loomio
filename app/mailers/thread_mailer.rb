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

  def motion_created(motion, user)
    @user = user
    @motion = motion
    @group = motion.group
    @rendered_motion_description = render_rich_text(motion.description, false) #should replace false with motion.uses_markdown in future
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_motion_created'
    locale = locale_fallback(user.locale, motion.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(motion.author),
            reply_to: motion.author_name_and_email,
            subject: "#{t(:proposal)}: #{@motion.name} - #{@group.name}"
    end
  end

  def motion_blocked(vote)
    @vote = vote
    @user = vote.user
    @motion = vote.motion
    @discussion = @motion.discussion
    @group = @motion.group
    @rendered_motion_description = render_rich_text(@motion.description, false) #should replace false with motion.uses_markdown in future
    locale = locale_fallback(@motion.author.locale, nil)
    I18n.with_locale(locale) do
      mail  to: @motion.author_email,
            reply_to: @group.admin_email,
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.proposal_blocked.subject", which: @motion.name)
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

  def motion_closed(motion, email)
    @motion = motion
    @group = motion.group
    locale = locale_fallback(User.find_by_email(email).locale, motion.author.locale)
    I18n.with_locale(locale) do
      mail  to: email,
            subject: t("email.proposal_closed.subject", which: @motion.name)
    end
  end

  def motion_outcome_created(motion, user)
    @user = user
    @motion = motion
    @group = motion.group
    @rendered_motion_description = render_rich_text(motion.description, false) #should replace false with motion.uses_markdown in future
    @utm_hash = UTM_EMAIL.merge utm_source: 'motion_outcome_created'
    locale = locale_fallback(user.locale, motion.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(motion.outcome_author),
            reply_to: motion.outcome_author.name_and_email,
            subject: "#{t("email.proposal_outcome.subject")}: #{@motion.name} - #{@group.name}"
    end
  end
end
