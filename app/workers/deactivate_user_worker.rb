class DeactivateUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by!(id: user_id)

    user.identities.delete_all

    user.update(name: nil,
                email: "deactivated-user-#{SecureRandom.uuid}@example.com",
                short_bio: nil,
                username: nil,
                avatar_kind: "initials",
                avatar_initials: nil,
                country: nil,
                region: nil,
                city: nil,
                current_sign_in_ip: nil,
                last_sign_in_ip: nil,
                deactivated_at: Time.now)

    Membership.where(user_id: user_id).update_all(archived_at: Time.now)

    group_ids = Membership.where(user_id: user_id).pluck(:group_id)
    Group.where(id: group_ids).map(&:update_memberships_count)

    MembershipRequest.where(user_id: user_id, responded_at: nil).destroy_all
  end
end
