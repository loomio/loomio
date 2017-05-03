class Communities::LoomioGroup < Communities::Base
  include Communities::NotifyLoomioGroup
  set_community_type :loomio_group

  validates :group, presence: true

  def to_user_community
    Communities::LoomioUsers.new(loomio_user_ids: group.member_ids, identifier: identifier)
  end

  def group
    @group = nil unless @group&.key == self.identifier
    @group ||= Group.find_by(key: self.identifier)
  end

  def group=(group)
    self.identifier = group.key
  end

  def includes?(member)
    member.is_admin_of?(self.group) ||
    (member.is_member_of?(self.group) && group.members_can_vote?)
  end
end
