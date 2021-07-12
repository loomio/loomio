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
    %w[all_memberships
      membership_requests
      discussions
      group_polls
      guest_discussions
      participated_polls].map do |relation|
      user.send(relation).pluck(:group_id)
    end.flatten.uniq
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
