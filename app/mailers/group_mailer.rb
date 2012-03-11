class GroupMailer < ActionMailer::Base
  default :from => "noreply@tautoko.co.nz"

  def new_membership_request(group)
    @group = group
    @admins = @group.admins.map(&:email)
    mail(:to => @admins, :subject => "[Tautoko: #{@group.name}] Membership waiting approval.")
  end

  def new_motion_created(motion)
    @motion = motion
    @group = @motion.group
    @group_members = []
    @group.memberships.each do |m|
      @group_members << m.user.email unless m.user.nil? or motion.author == m.user or m.access_level == 'request'
    end
    mail(:to => @group_members, :subject => "[Tautoko: #{@group.name}] New motion: #{@motion.name}.")
  end
end
