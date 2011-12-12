class GroupMailer < ActionMailer::Base
  default :from => "noreply@tautoko.co.nz"   

  def new_membership_request(group)
    @group = group
    @admins = @group.admins.map(&:email)
    mail(:to => @admins, :subject => "[Tautoko: #{@group.name}] Membership waiting approval.")
  end
  
  def new_motion_created(group_members, group, motion)
    @group = group
    @motion = motion
    @group_members = group_members
    #@group_members = @group.users.map{|u| u.email unless @motion.author == u or u.membership.access_level == 'request'}.compact!
    #@group_members = @group.memberships.map{|m| m.user.email unless m.user.nil? or @motion.author == m.user or m.access_level == 'request'}
    mail(:to => @group_members, :subject => "[Tautoko: #{@group.name}] New motion: #{@motion.name}.")
  end
end
