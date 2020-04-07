class MigrateUserWorker
  include Sidekiq::Worker

  attr_reader :source, :destination

  def perform(source_id, destination_id)
    @source = User.find_by!(id: source_id)
    @destination = User.find_by!(id: destination_id)
    delete_duplicates
    operations.each { |operation| ActiveRecord::Base.connection.execute(operation) }
    migrate_stances
    update_counters
    source.deactivate!
    UserMailer.delay.accounts_merged(destination.id)
  end

  SCHEMA = {
    ahoy_visits: :user_id,
    ahoy_events: :user_id,
    ahoy_messages: :user_id,
    attachments: :user_id,
    documents: :author_id,
    comments: :user_id,
    reactions: :user_id,
    discussion_readers: :user_id,
    discussions: :author_id,
    events: :user_id,
    groups: :creator_id,
    login_tokens: :user_id,
    membership_requests: [:requestor_id, :responder_id],
    memberships: [:user_id, :inviter_id],
    notifications: :user_id,
    oauth_applications: :owner_id,
    omniauth_identities: :user_id,
    outcomes: :author_id,
    poll_did_not_votes: :user_id,
    poll_unsubscriptions: :user_id,
    polls: :author_id,
    versions: :whodunnit,
    user_deactivation_responses: :user_id
  }.freeze

  def delete_duplicates
    Membership.delete(destination.memberships.
                      joins("INNER JOIN memberships source
                             ON source.group_id = memberships.group_id
                             AND source.user_id = #{source.id}").pluck(:"source.id"))

    DiscussionReader.delete(destination.discussion_readers.
                      joins("INNER JOIN discussion_readers source
                             ON source.discussion_id = discussion_readers.discussion_id
                             AND source.user_id = #{source.id}").pluck(:"source.id"))
  end

  def operations
    SCHEMA.map do |table, columns|
      Array(columns).map do |column_name|
        "UPDATE #{table} SET #{column_name} = #{destination.id} WHERE #{column_name} = #{source.id}"
      end
    end.flatten
  end

  def migrate_stances
    Stance.where(participant: source).update_all(participant_id: destination.id)
    Stance.where(participant: destination).update_all(latest: false)

    poll_ids = Stance.where(participant: destination).pluck(:poll_id).uniq
    Poll.where(id: poll_ids).each do |poll|
      poll.stances.where(participant: destination).where('cast_at is not null')
                  .order(created_at: :desc)
                  .first
                  .update_attribute(:latest, true)
    end
  end

  def update_counters
    destination.reload.groups.each do |group|
      group.update_memberships_count
      group.update_admin_memberships_count
      group.update_pending_memberships_count
    end

    [
      destination.polls,
      destination.group_polls,
      destination.participated_polls
    ].flatten.uniq.each do |poll|
      poll.update_uncast_stances_count
      poll.update_stances_count
      poll.update_stance_data
    end

    [source, destination].each do |user|
      user.update_memberships_count
    end
    destination.update_attribute(:sign_in_count, destination.sign_in_count + source.sign_in_count)
  end
end
