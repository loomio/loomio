class ContactableQuery
  def self.contactable(user:, actor:)
    (group_ids(user) & group_ids(actor)).any? ||
    (topic_ids(user) & topic_ids(actor)).any?
  end

  private
  def self.group_ids(user)
    ids = []
    ids.concat(user.all_memberships.pluck(:group_id))
    ids.concat(user.membership_requests.pluck(:group_id))
    ids.flatten.compact.uniq
  end

  def self.topic_ids(user)
    ids = Topic.where(group_id: user.group_ids).pluck(:id)
    ids.concat(user.guest_topic_ids)
    ids.uniq
  end
end
