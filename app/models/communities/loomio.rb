class Communities::Loomio < Communities::Base
  validates          :group, presence: true
  set_community_type :loomio
  set_custom_fields  :group_key

  def group
    @group ||= Group.find_by(key: group_key)
  end

  def group=(group)
    self.group_key = group.key
  end

  def includes?(participant)
    participant.is_member_of?(self.group) if self.group
  end

  def participants
    @participants ||= group.members
  end
end
