class MigrateUserService
  def initialize(new_id:, old_id:)
    @new_id = new_id
    @old_id = old_id
    @lines = []
  end

  def schema
    {
      contacts: :user_id,
      memberships: [:user_id, :inviter_id],
      membership_requests: [:requestor_id, :responder_id],
      groups: :creator_id,
      discussions: :author_id,
      drafts: :user_id,
      events: :user_id,
      invitations: [:inviter_id, :canceller_id],
      motions: [:author_id, :outcome_author_id],
      notifications: :user_id,
      omniauth_identities: :user_id,
      visits: :user_id,
      votes: :user_id,
      ahoy_events: :user_id,
      ahoy_messages: :user_id,
      attachments: :user_id,
      comment_votes: :user_id,
      comments: :user_id,
      discussion_readers: :user_id,
      network_coordinators: :coordinator_id,
      network_membership_requests: [:requestor_id, :responder_id],
      oauth_applications: :owner_id
    }
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
      ActiveRecord::Base.connection.execute line
    end

    # look into using
    # table.constantize.where(column_name => @old_id).delete_all
    delete_sql.each do |line|
      ActiveRecord::Base.connection.execute line
    end

    ActiveRecord::Base.connection.execute update_paperclip_versions_sql
  end

  # tests:
  # if there is a unique constaint, we fail but proceed with futher calls
  # eg: memberships
  # afterwards there are no instances of old_id left in the system
  #
  # todos:
  # versions.. updating whodunnit for previous versions of records
end
