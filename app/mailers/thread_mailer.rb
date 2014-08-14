class ThreadMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def new_discussion(user, discussion)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'
    send_thread_email_for(@discussion)
  end

  def new_comment(user, comment)
    @user = user
    @comment = comment
    @discussion = comment.discussion
    @rendered_comment_body = render_rich_text(comment.body, comment.uses_markdown)
    send_thread_email_for(@comment)
  end

  def new_vote(user, vote)
    @user = user
    @vote = vote
    @position = @vote.position
    @motion = @vote.motion
    @discussion = @motion.discussion
    send_thread_email_for(@vote)
  end

  def new_motion(user, motion)
    @user = user
    @motion = motion
    @discussion = motion.discussion
    @group = @discussion.group
    @rendered_motion_description = render_rich_text(@motion.description, false)
    send_thread_email_for(@motion)
  end

  def motion_closing_soon(user, motion)
    @user = user
    @motion = motion
    @discussion = motion.discussion
    @group = @discussion.group
    @rendered_motion_description = render_rich_text(@motion.description, false)
    send_thread_email_for(@motion)
  end

  #def motion_outcome_created(motion, user)
    #@user = user
    #@motion = motion
    #@group = motion.group
    #@rendered_motion_description = render_rich_text(motion.description, false) #should replace false with motion.uses_markdown in future
    #@utm_hash = UTM_EMAIL.merge utm_source: 'motion_outcome_created'
    #locale = locale_fallback(user.locale, motion.author.locale)
    #I18n.with_locale(locale) do
      #mail  to: user.email,
            #from: from_user_via_loomio(motion.outcome_author),
            #reply_to: motion.outcome_author.name_and_email,
            #subject: "#{t("email.proposal_outcome.subject")}: #{@motion.name} - #{@group.name}"
    #end
  #end
  #

  # Motion_closed is only sent to the motion.author
  def motion_closed(user, motion)
    @motion = motion
    @group = motion.group
    locale = locale_fallback(user.locale, motion.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.name_and_email,
            subject: t("email.proposal_closed.subject", which: @motion.name)
    end
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
