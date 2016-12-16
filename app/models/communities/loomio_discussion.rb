class Communities::LoomioDiscussion < Communities::Base
  set_community_type :loomio_discussion
  set_custom_fields  :discussion_key

  validates :discussion, presence: true

  def group
    self.discussion&.group
  end

  def discussion
    @discussion = nil unless @discussion&.key == self.discussion_key
    @discussion ||= Discussion.find_by(key: self.discussion_key)
  end

  def discussion=(discussion)
    self.discussion_key = discussion.key
  end

  def includes?(participant)
    participant.is_admin_of?(self.group) ||
    self.group.members_can_vote? && participant.is_member_of?(self.group)
  end

  def participants
    @participants ||= group.members_can_vote? ? group.members : group.admins
  end
end
