class UserMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def missed_yesterday(user, time_since = nil, unread = true)
    @user = user
    @time_start = time_since || 24.hours.ago
    @time_finish = Time.zone.now
    @time_frame = @time_start...@time_finish

    @utm_hash = UTM_EMAIL.merge utm_source: 'missed_yesterday'
    if unread
      @discussions_by_group = Queries::VisibleDiscussions.new(user: user,
                                                            groups: user.inbox_groups).
                                                            unread.
                                                            active_since(@time_start).
                                                            group_by(&:group)
    else
      @discussions_by_group = Queries::VisibleDiscussions.new(user: user,
                                                            groups: user.inbox_groups).
                                                            active_since(@time_start).
                                                            group_by(&:group)
    end

    unless @discussions_by_group.empty?
      locale = best_locale(user.locale)
      I18n.with_locale(locale) do
        mail to: user.email,
             subject: t("email.missed_yesterday.subject"),
             css: 'missed_yesterday'
      end
    end
  end

  def daily_activity(user, activity, since_time)
    @user = user
    @activity = activity
    @since_time = since_time
    @since_time_formatted = since_time.strftime('%A, %-d %B')
    @groups = user.groups.sort{|a,b| a.full_name <=> b.full_name }
    locale = best_locale(user.locale)
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
    locale = best_locale(user.locale, comment.author.locale)
    I18n.with_locale(locale) do
      mail to: @user.email,
           from: from_user_via_loomio(comment.author),
           reply_to: comment.author.name_and_email,
           subject: t("email.mentioned.subject", who: comment.author.name, which: comment.group.name)
    end
  end

  def group_membership_approved(user, group)
    @user = user
    @group = group
    locale = best_locale(user.locale, User.find_by_email(@group.admin_email).locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            reply_to: @group.admin_email,
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.group_membership_approved.subject")
    end
  end

  def motion_closing_soon(user, motion)
    @user = user
    @motion = motion
    @group = motion.group
    @rendered_motion_description = render_rich_text(motion.description, false) #later: change false to motion.uses_markdown
    @utm_hash = UTM_EMAIL.merge utm_source: 'motion_closing_soon'
    locale = best_locale(user.locale, @motion.author.locale)
    I18n.with_locale(locale) do
      mail to: user.email,
           from: from_user_via_loomio(motion.author),
           reply_to: motion.author_name_and_email,
           subject: "#{t(:"email.proposal_closing_soon.closing_in_24_hours")}: #{motion.name} - #{@group.name}"
    end
  end

  def added_to_group(user: nil, inviter: nil, group: nil, message: nil)
    @user = user
    @inviter = inviter
    @group = group
    @message = message
    locale = best_locale(user.locale, inviter.locale)
    I18n.with_locale(locale) do
      mail to: user.email,
           from: from_user_via_loomio(inviter),
           reply_to: inviter.name_and_email,
           subject: t("email.user_added_to_a_group.subject", which_group: group.name, who: inviter.name)
    end
  end

  def added_to_discussion(user: nil, inviter: nil, discussion: nil, message: nil)
    @user = user
    @inviter = inviter
    @discussion = discussion
    @message = message
    locale = best_locale(user.locale, inviter.locale)
    I18n.with_locale(locale) do
      mail to: user.email,
           from: from_user_via_loomio(inviter),
           reply_to: inviter.name_and_email,
           subject: t("email.to_join_discussion.subject", who: inviter.name)
    end
  end
end
