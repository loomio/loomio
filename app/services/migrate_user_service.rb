class MigrateUserService
  def initialize(new_id:, old_id:)
    @new_id = new_id
    @old_id = old_id
    @lines = []
  end

  def schema
    {
      visits: :user_id,
      ahoy_events: :user_id,
      ahoy_messages: :user_id,
      groups: :creator_id,
      memberships: [:user_id, :inviter_id],
      discussions: :author_id,
      comments: :user_id,
      comment_votes: :user_id,
      motions: [:author_id, :outcome_author_id],
      votes: :user_id,
      attachments: :user_id,
      contacts: :user_id,
      did_not_votes: :user_id,
      discussion_readers: :user_id,
      drafts: :user_id,
      events: :user_id,
      invitations: [:inviter_id, :canceller_id],
      membership_requests: [:requestor_id, :responder_id],
      network_coordinators: :coordinator_id,
      network_membership_requests: [:requestor_id, :responder_id],
      notifications: :user_id,
      oauth_applications: :owner_id,
      omniauth_identities: :user_id,
      user_deactivation_responses: :user_id,
    }
  end

  def update_counters
    User.find(@new_id).groups.each do |group|
      group.update_memberships_count
      group.update_admin_memberships_count
      group.update_invitations_count
      group.motions.each do |motion|
        motion.update_votes_count
        motion.update_voters_count
        motion.update_vote_counts!
      end
    end
  end

  def update_version_owners
    PaperTrail::Version.where(item_type: ['Discussion', 'Comment', 'Motion'], whodunnit: "#{@old_id}").update_all(whodunnit: "#{@new_id}")
  end

  def update_sql
    lines = []
    schema.each_pair do |table, columns|
      Array(columns).map(&:to_s).each do |column_name|
        lines << "UPDATE #{table} SET #{column_name} = #{@new_id} WHERE #{column_name} = #{@old_id}"
      end
    end
    lines
  end

  def update_paperclip_versions_sql
    "UPDATE versions SET whodunnit = '#{@new_id}' WHERE whodunnit = '#{@old_id}'"
  end

  def delete_sql
    lines = []
    schema.each_pair do |table, columns|
      Array(columns).map(&:to_s).each do |column_name|
        lines << "DELETE FROM #{table} WHERE #{column_name} = #{@old_id}"
      end
    end
    lines
  end

  def commit!
    update_sql.each do |line|
      begin
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute line
        end
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end

    # look into using
    # table.constantize.where(column_name => @old_id).delete_all
    # delete_sql.each do |line|
    #   ActiveRecord::Base.connection.execute line
    # end

    # User.find(@old_id).destroy

    ActiveRecord::Base.connection.execute update_paperclip_versions_sql
    update_counters
    update_version_owners
  end
end
