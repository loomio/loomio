class RevokeMembershipsForDeactivatedUsers < ActiveRecord::Migration[7.0]
  def change
    User.where.not(deactivated_at: nil).find_each do |user|
      group_ids = Membership.active.where(user_id: user.id).pluck(:group_id)
      if group_ids.count > 0
        GenericWorker.perform_async("MembershipService", "revoke_by_id", group_ids, user.id, user.id, user.deactivated_at)
      end
    end
  end
end
