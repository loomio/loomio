class Communities::LoomioGroup < Communities::Base
  set_community_type :loomio_group

  validates :group, presence: true

  def to_user_community
    Communities::LoomioUsers.new(loomio_user_ids: members.pluck(:id), group_key: identifier)
  end

  def group
    @group = nil unless @group&.key == self.identifier
    @group ||= Group.find_by(key: self.idenfifier)
  end

  def group=(group)
    self.identifier = group.key
  end

  def includes?(member)
    member.is_admin_of?(self.group) ||
    (member.is_member_of?(self.group) && group.members_can_vote?)
  end

  def members
    @members ||= group.members
  end

  def notify!(event)
    # this is currently handled by Event subclasses, but the logic
    # could be moved here when we need to notify multiple groups of
    # poll events
  end
end
