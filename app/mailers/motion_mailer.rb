class MotionMailer < ActionMailer::Base
  default :from => "\"Loomio\" <noreply@loom.io>"

  def new_motion_created(motion, email)
    @motion = motion
    @group = motion.group
    mail(to: email, subject: "[Loomio: #{@group.name}] New proposal - #{@motion.name}")
  end

  def motion_blocked(vote)
    @vote = vote
    @user = vote.user
    @motion = vote.motion
    @discussion = @motion.discussion
    @group = @motion.group
    mail(to: @motion.author.email,
         subject: "[Loomio: #{@group.name}] Proposal blocked - #{@motion.name}")
  end
end
