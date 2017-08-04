class MigrateUserService
  def self.migrate!(source:, destination:)
    new(source: source, destination: destination).migrate!
  end

  def initialize(source:, destination:)
    @source = source
    @destination = destination
  end

  SCHEMA = {
    ahoy_events: :user_id,
    ahoy_messages: :user_id,
    attachments: :user_id,
    comments: :user_id,
    comment_votes: :user_id,
    contacts: :user_id,
    discussion_readers: :user_id,
    discussions: :author_id,
    drafts: :user_id,
    events: :user_id,
    group_visits: :user_id,
    groups: :creator_id,
    invitations: [:inviter_id, :canceller_id],
    login_tokens: :user_id,
    membership_requests: [:requestor_id, :responder_id],
    memberships: [:user_id, :inviter_id],
    notifications: :user_id,
    oauth_applications: :owner_id,
    omniauth_identities: :user_id,
    organisation_visits: :user_id,
    outcomes: :author_id,
    poll_did_not_votes: :user_id,
    poll_unsubscriptions: :user_id,
    polls: :author_id,
    stances: :participant_id,
    versions: :whodunnit,
    visits: :user_id,
    user_deactivation_responses: :user_id
  }.freeze

  def update_counters
    @destination.reload.groups.each do |group|
      group.update_memberships_count
      group.update_admin_memberships_count
      group.update_invitations_count
      group.update_pending_invitations_count
      group.update_announcement_recipients_count
    end

    [
     @destination.polls,
     @destination.group_polls,
     @destination.participated_polls
    ].flatten.uniq.each do |poll|
      poll.update_undecided_user_count
      poll.update_stances_count
      poll.update_stance_data
    end
  end

  def migrate!
    operations.each { |operation| execute(operation) }
    update_counters
    @source.deactivate!
  end

  def operations
    SCHEMA.map do |table, columns|
      Array(columns).map(&:to_s).map do |column_name|
        [
          "UPDATE #{table} SET #{column_name} = #{@destination.id} WHERE #{column_name} = #{@source.id}",
          "DELETE FROM #{table} WHERE #{column_name} = #{@source.id}"
        ]
      end
    end.flatten
  end

  def execute(line)
    ActiveRecord::Base.transaction { ActiveRecord::Base.connection.execute(line) }
  rescue ActiveRecord::RecordNotUnique
    puts "Conflict executing #{line}"
  end
end
