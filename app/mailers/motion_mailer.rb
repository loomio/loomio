class MotionMailer < ActionMailer::Base
  default from: "noreply@loom.io"

  def new_motion_created(motion, email)
    @motion = motion
    @group = motion.group
    #email_addresses = []
    #@group.users.each do |user|
      #email_addresses << user.email unless motion.author == user
    #end
    mail(to: email, subject: "[Loomio: #{@group.name}] New motion - #{@motion.name}")
  end

  def motion_blocked(vote)
    @vote = vote
    @user = vote.user
    @motion = vote.motion
    @group = @motion.group
    mail(to: @motion.author.email,
         subject: "[Loomio: #{@group.name}] Motion blocked - #{@motion.name}")
  end
end
