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
    self.group.community.includes?(participant)
  end

  def participants
    self.group.community.participants
  end
end
