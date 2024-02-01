class MigrateGuestOnDiscussionReadersAndStances
  include Sidekiq::Worker

  def perform(group_id)
    member_ids = Membership.active.where(group_id: group_id).pluck(:user_id)

    DiscussionReader
      .active.joins(:discussion)
      .where('discussions.group_id': group_id)
      .where.not(inviter_id: nil)
      .where.not(user_id: member_ids)
      .update_all(guest: true)

    Stance
      .latest.joins(:poll)
      .where('polls.group_id': group_id)
      .where.not(inviter_id: nil)
      .where.not(participant_id: member_ids)
      .update_all(guest: true)
  end
end
