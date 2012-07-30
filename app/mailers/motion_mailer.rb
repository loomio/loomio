class MotionMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_motion_created(motion, email)
    @motion = motion
    @group = motion.group
    mail( to: email, 
          reply_to: @group.admin_email,
          subject: "[Loomio: #{@group.full_name}] New proposal - #{@motion.name}")
  end

  def motion_blocked(vote)
    @vote = vote
    @user = vote.user
    @motion = vote.motion
    @discussion = @motion.discussion
    @group = @motion.group
    mail( to: @motion.author.email,
          reply_to: @group.admin_email,
          subject: "[Loomio: #{@group.full_name}] Proposal blocked - #{@motion.name}")
  end
end
