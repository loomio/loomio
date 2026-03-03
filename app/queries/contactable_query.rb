class ContactableQuery
  def self.contactable(user:, actor:)
    # the users have a group (membership or membership request) in common
    # the users have a discussion or poll in common
    # membership, membership_request, discussion or poll in common.
    (group_ids(user) & group_ids(actor)).any? ||
    (discussion_ids(user) & discussion_ids(actor)).any? ||
    (poll_ids(user) & poll_ids(actor)).any?
  end

  private
  def self.group_ids(user)
    ids = []
    ids.concat(user.all_memberships.pluck(:group_id))
    ids.concat(user.membership_requests.pluck(:group_id))
    ids.concat(Topic.where(id: user.guest_topic_ids).pluck(:group_id))
    ids.flatten.compact.uniq
  end

  def self.discussion_ids(user)
    ids = user.discussions.pluck(:id)
    ids.concat(Topic.where(id: user.guest_topic_ids, topicable_type: 'Discussion').pluck(:topicable_id))
    ids.uniq
  end

  def self.poll_ids(user)
    %w[group_polls participated_polls].map do |relation|
      user.send(relation).pluck(:id)
    end.flatten.uniq
  end
end
