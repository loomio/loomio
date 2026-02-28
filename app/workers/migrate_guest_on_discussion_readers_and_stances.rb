class MigrateGuestOnDiscussionReadersAndStances
  include Sidekiq::Worker

  def perform(group_id)
    member_ids = Membership.active.where(group_id: group_id).pluck(:user_id)

    TopicReader
      .active
      .joins("INNER JOIN topics ON topics.id = topic_readers.topic_id")
      .where('topics.group_id': group_id)
      .where.not(inviter_id: nil)
      .where.not(user_id: member_ids)
      .update_all(guest: true)
  end
end
