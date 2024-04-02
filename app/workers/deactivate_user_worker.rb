class DeactivateUserWorker
  include Sidekiq::Worker

  def perform(user_id, actor_id)
    user = User.find(user_id)
    deactivated_at = DateTime.now

    User.transaction do
      user.update(deactivated_at: deactivated_at, deactivator_id: actor_id)
      group_ids = Membership.where(user_id: user_id).pluck(:group_id)
      Group.where(id: group_ids).map(&:update_memberships_count)
      MembershipRequest.where(requestor_id: user_id, responded_at: nil).destroy_all
    end

    SearchService.reindex_by_author_id(user.id)
  end
end
