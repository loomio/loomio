class MotionMailer < BaseMailer
  def new_motion_created(motion, user)
    @user = user
    @motion = motion
    @group = motion.group
    set_email_locale(user.language_preference, motion.author.language_preference)
    @rendered_motion_description = render_rich_text(motion.description, false) #should replace false with motion.uses_markdown in future
    mail  to: user.email,
          reply_to: motion.author_email,
          subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_proposal.subject", which: @motion.name)
  end

  def motion_closed(motion, email)
    @motion = motion
    @group = motion.group
    set_email_locale(User.find_by_email(email).language_preference, motion.author.language_preference)
    mail  to: email,
          subject: "#{email_subject_prefix(@group.full_name)} " + t("email.proposal_closed.subject", which: @motion.name)
  end

  def motion_blocked(vote)
    @vote = vote
    @user = vote.user
    @motion = vote.motion
    @discussion = @motion.discussion
    @group = @motion.group
    set_email_locale(@motion.author.language_preference, nil)
    @rendered_motion_description = render_rich_text(@motion.description, false) #should replace false with motion.uses_markdown in future
    mail  to: @motion.author_email,
          reply_to: @group.admin_email,
          subject: "#{email_subject_prefix(@group.full_name)} " + t("email.proposal_blocked.subject", which: @motion.name)
  end
end
