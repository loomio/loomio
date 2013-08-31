class UserMailer < BaseMailer
  def daily_activity(user, activity, since_time)
    @user = user
    @activity = activity
    @since_time = since_time
    @since_time_formatted = since_time.strftime('%A, %-d %B')
    @groups = user.groups.sort{|a,b| a.full_name <=> b.full_name }
    locale = best_locale(user.language_preference, nil)
    I18n.with_locale(locale) do
      mail to: @user.email,
           subject: t("email.daily_activity.subject")
    end
  end

  def mentioned(user, comment)
    @user = user
    @comment = comment
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    @discussion = comment.discussion
    locale = best_locale(user.language_preference, comment.author.language_preference)
    I18n.with_locale(locale) do
      mail to: @user.email,
           subject: t("email.mentioned.subject", who: comment.author.name, which: comment.group.name)
    end
  end

  def group_membership_approved(user, group)
    @user = user
    @group = group
    locale = best_locale(user.language_preference, User.find_by_email(@group.admin_email).language_preference)
    I18n.with_locale(locale) do
      mail  :to => user.email,
            :reply_to => @group.admin_email,
            :subject => "#{email_subject_prefix(@group.full_name)} " + t("email.group_membership_approved.subject")
    end
  end

  def motion_closing_soon(user, motion)
    @user = user
    @motion = motion
    @rendered_motion_description = render_rich_text(motion.description, false) #later: change false to motion.uses_markdown
    locale = best_locale(user.language_preference, @motion.author.language_preference)
    I18n.with_locale(locale) do
      mail to: user.email,
           reply_to: @motion.author.email,
           subject: "#{email_subject_prefix(@motion.group.full_name)} " + t("email.proposal_closing_soon.subject", which: @motion.name)
    end
  end

  def added_to_a_group(user, inviter, group)
    @user = user
    @group = group
    locale = best_locale(user.language_preference, inviter.language_preference)
    I18n.with_locale(locale) do
      mail to: user.email,
           reply_to: inviter.email,
           subject: t("email.added_to_a_group.subject", which: group.name)
    end
  end
end
