class MigrateUserService
  def self.migrate!(source:, destination:)
    new(source: source, destination: destination).migrate!
  end

  attr_reader :source, :destination

  def initialize(source:, destination:)
    @source = source
    @destination = destination
  end

  def migrate!
    operations.each { |operation| execute(operation) }
    migrate_stances
    update_counters
    source.deactivate!
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
    versions: :whodunnit,
    visits: :user_id,
    user_deactivation_responses: :user_id
  }.freeze

  def operations
    SCHEMA.map do |table, columns|
      Array(columns).map(&:to_s).map do |column_name|
        [
          "UPDATE #{table} SET #{column_name} = #{destination.id} WHERE #{column_name} = #{source.id}",
          "DELETE FROM #{table} WHERE #{column_name} = #{source.id}"
        ]
      end
    end.flatten
  end

  def migrate_stances
    poll_ids = source.participated_poll_ids & destination.participated_poll_ids
    Stance.where(participant: source).update_all(participant_id: destination.id)
    Stance.where(participant: destination, poll_id: poll_ids).update_all(latest: false)

    Poll.where(id: poll_ids).each do |poll|
      poll.stances.where(participant: destination)
                  .order(created_at: :desc)
                  .first
                  .update_attribute(:latest, true)
    end
  end

  def execute(line)
    ActiveRecord::Base.transaction { ActiveRecord::Base.connection.execute(line) }
  rescue ActiveRecord::RecordNotUnique
    puts "Conflict executing #{line}"
  end

  def update_counters
    destination.reload.groups.each do |group|
      group.update_memberships_count
      group.update_admin_memberships_count
      group.update_invitations_count
      group.update_pending_invitations_count
      group.update_announcement_recipients_count
    end

    [
      destination.polls,
      destination.group_polls,
      destination.participated_polls
    ].flatten.uniq.each do |poll|
      poll.update_undecided_user_count
      poll.update_stances_count
      poll.update_stance_data
    end
  end
end
