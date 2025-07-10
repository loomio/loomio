class MigrateDiscussionReadersForDeactivatedMembersWorker
  include Sidekiq::Worker

  def perform
    Membership.includes(:user).where("revoked_at is not null").each do |m|
      rel = DiscussionReader
            .joins(:discussion)
            .where(
              user_id: m.user_id,
              'discussion.group_id': m.group_id,
              guest: false,
              revoked_at: nil,
            )
      if m.user.present?
        updated_count = rel.update_all(revoked_at: m.revoked_at, revoker_id: m.revoker_id)
        puts "updated #{updated_count} readers in group_id: #{m.group_id} for user_id #{m.user_id}"
      end
    end
  end
end
