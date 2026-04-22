module CleanupService
  def self.delete_orphan_records
    [Group,
     Membership,
     MembershipRequest,
     Discussion,
     Subscription,
     DiscussionReader,
     Comment,
     Poll,
     PollOption,
     Stance,
     StanceChoice,
     Outcome,
     Event,
     Notification].each do |model|
      count = model.dangling.delete_all
      puts "deleted #{count} dangling #{model.to_s} records"
    end

    PaperTrail::Version.where(item_type: 'Motion').delete_all
  end

  def self.destroy_orphan_users
    user_ids = orphan_user_ids

    if user_ids.empty?
      puts "No orphan users to destroy"
      return
    end

    User.where(id: user_ids).find_each do |user|
      DeactivateUserWorker.perform_async(user.id, user.id)
    end

    puts "Enqueued #{user_ids.size} orphan users for deactivation"
  end

  def self.orphan_user_ids
    User.where(deactivated_at: nil)
        .where("last_sign_in_at < ?", 1.year.ago)
        .where("NOT EXISTS (SELECT 1 FROM memberships       WHERE memberships.user_id        = users.id)")
        .where("NOT EXISTS (SELECT 1 FROM comments          WHERE comments.user_id           = users.id)")
        .where("NOT EXISTS (SELECT 1 FROM discussions       WHERE discussions.author_id      = users.id)")
        .where("NOT EXISTS (SELECT 1 FROM polls             WHERE polls.author_id            = users.id)")
        .where("NOT EXISTS (SELECT 1 FROM stances           WHERE stances.participant_id     = users.id)")
        .pluck(:id)
  end
end
