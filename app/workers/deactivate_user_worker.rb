class DeactivateUserWorker
  include Sidekiq::Worker

  def perform(user_id, actor_id)
    user = User.find(user_id)
    deactivated_at = DateTime.now
    group_ids = Membership.active.where(user_id: user_id).pluck(:group_id)

    User.transaction do

      MembershipService.revoke_by_id(group_ids, user_id, actor_id, deactivated_at)
      
      user.update(deactivated_at: deactivated_at, deactivator_id: actor_id)
      MembershipRequest.where(requestor_id: user_id, responded_at: nil).destroy_all
    end

    SearchService.reindex_by_author_id(user.id)
  end
end
