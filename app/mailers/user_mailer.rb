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
      @discussions = Queries::VisibleDiscussions.new(user: user,
                                                     groups: user.inbox_groups).
                                                     unread.
                                                     active_since(@time_start)
    else
      @discussions = Queries::VisibleDiscussions.new(user: user,
                                                     groups: user.inbox_groups).
                                                     active_since(@time_start)
    end

    unless @discussions.empty? or @user.inbox_groups.empty?
      @discussions_by_group = @discussions.group_by(&:group)
      locale = locale_fallback(user.locale)

      I18n.with_locale(locale) do
        mail to: user.email,
             subject: t("email.missed_yesterday.subject"),
             css: 'missed_yesterday'
      end
    end
  end

  def group_membership_approved(user, group)
    @user = user
    @group = group
    locale = locale_fallback(user.locale, User.find_by_email(@group.admin_email).locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            reply_to: @group.admin_email,
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.group_membership_approved.subject")
    end
  end

  def added_to_group(user: nil, inviter: nil, group: nil, message: nil)
    @user = user
    @inviter = inviter
    @group = group
    @message = message

    locale = locale_fallback(user.try(:locale), inviter.try(:locale))
    I18n.with_locale(locale) do
      mail to: user.email,
           from: from_user_via_loomio(inviter),
           reply_to: inviter.name_and_email,
           subject: t("email.user_added_to_a_group.subject", which_group: group.name, who: inviter.name)
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

  # Motion created, closing soon, and outcome_created can all go to
  # users as stand alone mail, or as part of the thread_mailer.
  def motion_created(motion, user)
    @user = user
    @motion = motion
    @group = motion.group
    @rendered_motion_description = render_rich_text(motion.description, false) #should replace false with motion.uses_markdown in future
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_motion_created'
    locale = locale_fallback(user.locale, motion.author.locale)
    # if subscribed use thread_subject
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(motion.author),
            reply_to: motion.author_name_and_email,
            subject: "#{t(:proposal)}: #{@motion.name} - #{@group.name}"
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

  # Motion_blocked is only sent to the motion.author
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

  # Motion_closed is only sent to the motion.author
  def motion_closed(motion, email)
    @motion = motion
    @group = motion.group
    locale = locale_fallback(User.find_by_email(email).locale, motion.author.locale)
    I18n.with_locale(locale) do
      mail  to: email,
            subject: t("email.proposal_closed.subject", which: @motion.name)
    end
  end
end
