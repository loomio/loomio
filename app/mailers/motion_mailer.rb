class MotionMailer < ActionMailer::Base
  default from: "noreply@loom.io"

  def new_motion_created(motion)
    @motion = motion
    @group = motion.group
    email_addresses = []
    @group.users.each do |user|
      email_addresses << user.email unless motion.author == user
    end
    mail(to: email_addresses, subject: "[Loomio: #{@group.name}] New motion: #{motion.name}.")
  end
end
