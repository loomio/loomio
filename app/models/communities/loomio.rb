class Communities::Loomio < Communities::Base
  set_community_type :loomio
  set_custom_fields  :group_key

  validates :group, presence: true

  def group
    Group.find_by(key: self.group_key)
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
