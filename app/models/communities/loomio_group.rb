class Communities::LoomioGroup < Communities::Base
  include Communities::NotifyLoomioGroup
  include Communities::NotifyThirdParty
  set_community_type :loomio_group
  set_custom_fields :slack_channel_id, :slack_channel_name

  validates :group, presence: true
  delegate :slack_team_id, to: :identity, allow_nil: true

  alias :channel :slack_channel_id

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
