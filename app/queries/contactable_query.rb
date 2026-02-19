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
    ids.concat(user.discussions.joins(:topic).pluck('topics.group_id'))
    ids.concat(user.group_polls.joins(:topic).pluck('topics.group_id'))
    ids.concat(user.guest_discussions.joins(:topic).pluck('topics.group_id'))
    ids.concat(user.participated_polls.joins(:topic).pluck('topics.group_id'))
    ids.flatten.compact.uniq
  end

  def self.discussion_ids(user)
    %w[discussions guest_discussions].map do |relation|
      user.send(relation).pluck(:id)
    end.flatten.uniq
  end

  def self.poll_ids(user)
    %w[group_polls participated_polls].map do |relation|
      user.send(relation).pluck(:id)
    end.flatten.uniq
  end
end
