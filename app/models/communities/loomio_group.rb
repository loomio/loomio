class Communities::LoomioGroup < Communities::Base
  set_community_type :loomio_group
  set_custom_fields  :group_key

  validates :group, presence: true

  def to_user_community
    Communities::LoomioUsers.new(loomio_user_ids: participants.pluck(:id), group_key: self.group_key)
  end

  def group
    @group = nil unless @group&.key == self.group_key
    @group ||= Group.find_by(key: self.group_key)
  end

  def group=(group)
    self.group_key = group.key
  end

  def includes?(participant)
    participant.is_admin_of?(self.group) ||
    (participant.is_member_of?(self.group) && group.members_can_vote?)
  end

  def participants
    @participants ||= group.members
  end
end
