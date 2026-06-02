module CleanupService
  DANGLING_RECORD_SCOPES = {
    "Group.missing_parent" => :groups_missing_parent,
    "Membership.missing_group" => :memberships_missing_group,
    "MembershipRequest.missing_group" => :membership_requests_missing_group,
    "Discussion.missing_group" => :discussions_missing_group,
    "Poll.missing_group" => :polls_missing_group,
    "PollOption.missing_poll" => :poll_options_missing_poll,
    "Stance.missing_poll" => :stances_missing_poll,
    "StanceChoice.missing_stance" => :stance_choices_missing_stance,
    "Outcome.missing_poll" => :outcomes_missing_poll,
    "Topic.missing_group" => :topics_missing_group,
    "TopicReader.missing_topic_or_user" => :topic_readers_missing_topic_or_user,
    "Comment.missing_event" => :comments_missing_event,
    "Comment.missing_parent" => :comments_missing_parent_not_missing_event,
    "Event.missing_topic" => :events_missing_topic,
    "Notification.missing_event_or_user" => :notifications_missing_event_or_user,
    "Subscription.missing_group" => :subscriptions_missing_group
  }.freeze

  ORPHAN_USER_REFERENCES = {
    chatbots: %i[author_id],
    comments: %i[user_id discarded_by],
    demos: %i[author_id],
    discussion_templates: %i[author_id discarded_by],
    discussions: %i[author_id discarded_by],
    events: %i[user_id],
    groups: %i[creator_id],
    member_email_aliases: %i[user_id author_id],
    membership_requests: %i[requestor_id responder_id],
    memberships: %i[user_id inviter_id revoker_id],
    notifications: %i[user_id actor_id],
    outcomes: %i[author_id],
    poll_templates: %i[author_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
    stance_receipts: %i[voter_id inviter_id],
    stances: %i[participant_id inviter_id revoker_id],
    tasks: %i[author_id doer_id],
    tasks_users: %i[user_id],
    topic_readers: %i[user_id inviter_id revoker_id],
    user_deactivation_responses: %i[user_id],
    webhooks: %i[author_id actor_id]
  }.freeze

  def self.audit_orphan_records
    audit = orphan_record_audit

    puts "Dangling records:"
    print_audit_counts(audit[:dangling_records])
    puts "Orphan PaperTrail versions:"
    print_audit_counts(audit[:orphan_versions])

    audit
  end

  def self.delete_orphan_records
    dangling_record_scopes.each do |label, scope|
      count = destroy_records(scope)
      puts "destroyed #{count} dangling #{label} records"
    end

    delete_orphan_versions
  end

  def self.orphan_record_audit
    {
      dangling_records: dangling_record_scopes.transform_values { |scope| unique_count(scope) },
      orphan_versions: orphan_version_scopes.transform_values(&:count)
    }
  end

  def self.dangling_record_scopes
    DANGLING_RECORD_SCOPES.transform_values { |method_name| public_send(method_name) }
  end

  def self.cleanup_tables
    (dangling_record_scopes.values.map { |scope| scope.klass.table_name } + [PaperTrail::Version.table_name]).uniq.sort
  end

  def self.groups_missing_parent
    Group
      .joins('LEFT JOIN groups parents ON parents.id = groups.parent_id')
      .where('groups.parent_id IS NOT NULL AND parents.id IS NULL')
  end

  def self.memberships_missing_group
    Membership
      .joins('LEFT JOIN groups g ON memberships.group_id = g.id')
      .where('memberships.group_id IS NOT NULL AND g.id IS NULL')
  end

  def self.membership_requests_missing_group
    MembershipRequest
      .joins('LEFT JOIN groups ON groups.id = group_id')
      .where('groups.id IS NULL')
  end

  def self.discussions_missing_group
    Discussion
      .joins(:topic)
      .joins('LEFT JOIN groups g ON topics.group_id = g.id')
      .where('topics.group_id IS NOT NULL AND g.id IS NULL')
  end

  def self.polls_missing_group
    Poll
      .joins('LEFT JOIN topics t ON t.id = polls.topic_id')
      .joins('LEFT JOIN groups g ON g.id = t.group_id')
      .where('t.group_id IS NOT NULL AND g.id IS NULL')
  end

  def self.poll_options_missing_poll
    PollOption
      .joins('LEFT JOIN polls ON polls.id = poll_id')
      .where('polls.id IS NULL')
  end

  def self.stances_missing_poll
    Stance
      .joins('LEFT JOIN polls ON polls.id = poll_id')
      .where('polls.id IS NULL')
  end

  def self.stance_choices_missing_stance
    StanceChoice
      .joins('LEFT JOIN stances ON stances.id = stance_id')
      .where('stances.id': nil)
  end

  def self.outcomes_missing_poll
    Outcome
      .joins('LEFT JOIN polls ON polls.id = poll_id')
      .where('polls.id IS NULL')
  end

  def self.topics_missing_group
    Topic
      .joins_groups
      .where('topics.group_id IS NOT NULL AND groups.id IS NULL')
  end

  def self.topic_readers_missing_topic_or_user
    TopicReader
      .joins('LEFT JOIN topics ON topics.id = topic_id LEFT JOIN users ON users.id = user_id')
      .where('topics.id IS NULL OR users.id IS NULL')
  end

  def self.comments_missing_event
    Comment
      .joins("LEFT JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id")
      .where('events.id IS NULL')
  end

  def self.comments_missing_parent
    Comment
      .joins("LEFT JOIN discussions parent_discussions ON comments.parent_type = 'Discussion' AND parent_discussions.id = comments.parent_id")
      .joins("LEFT JOIN comments parent_comments ON comments.parent_type = 'Comment' AND parent_comments.id = comments.parent_id")
      .where("(comments.parent_type = 'Discussion' AND parent_discussions.id IS NULL) OR (comments.parent_type = 'Comment' AND parent_comments.id IS NULL)")
  end

  def self.comments_missing_parent_not_missing_event
    comments_missing_parent.where.not(id: comments_missing_event.select(:id))
  end

  def self.events_missing_topic
    Event
      .joins('LEFT JOIN topics ON events.topic_id = topics.id')
      .where('events.topic_id IS NOT NULL AND topics.id IS NULL')
  end

  def self.notifications_missing_event_or_user
    Notification
      .joins('LEFT JOIN events e ON notifications.event_id = e.id LEFT JOIN users u ON u.id = notifications.user_id')
      .where('e.id IS NULL OR u.id IS NULL')
  end

  def self.subscriptions_missing_group
    Subscription
      .joins('LEFT JOIN groups ON subscriptions.id = groups.subscription_id')
      .where('groups.id IS NULL')
  end

  def self.delete_orphan_versions
    orphan_version_scopes.sum do |item_type, scope|
      count = scope.delete_all
      puts "deleted #{count} orphan #{item_type} version records"
      count
    end
  end

  def self.orphan_version_scopes
    PaperTrail::Version.distinct.pluck(:item_type).index_with do |item_type|
      orphan_version_scope_for(item_type)
    end
  end

  def self.delete_orphan_versions_for(item_type)
    orphan_version_scope_for(item_type).delete_all
  end

  def self.destroy_records(scope)
    count = 0

    PaperTrail.request(enabled: false) do
      scope.find_each do |record|
        record.destroy!
        count += 1
      end
    end

    count
  end

  def self.orphan_version_scope_for(item_type)
    model = item_type.safe_constantize

    unless model.is_a?(Class) && model < ActiveRecord::Base && model.table_exists? && model.primary_key
      return PaperTrail::Version.where(item_type: item_type)
    end

    version_table = PaperTrail::Version.quoted_table_name
    item_table = model.quoted_table_name
    primary_key = model.connection.quote_column_name(model.primary_key)

    PaperTrail::Version
      .where(item_type: item_type)
      .where("NOT EXISTS (SELECT 1 FROM #{item_table} WHERE #{item_table}.#{primary_key} = #{version_table}.item_id)")
  end

  def self.destroy_orphan_users
    user_ids = orphan_user_ids

    if user_ids.empty?
      puts "No orphan users to delete"
      return
    end

    User.where(id: user_ids).find_each do |user|
      PaperTrail::Version.where(item_type: 'User', item_id: user.id).delete_all
      PgSearch::Document.where(author_id: user.id).delete_all

      PaperTrail.request(enabled: false) do
        user.destroy!
      end
    end

    puts "Deleted #{user_ids.size} orphan users"
  end

  def self.orphan_user_ids
    ORPHAN_USER_REFERENCES.reduce(User.where(deactivated_at: nil).where("last_sign_in_at < ?", 1.year.ago)) do |scope, (table, columns)|
      columns.reduce(scope) do |column_scope, column|
        column_scope.where("NOT EXISTS (SELECT 1 FROM #{table} WHERE #{table}.#{column} = users.id)")
      end
    end.pluck(:id)
  end

  def self.unique_count(scope)
    scope.unscope(:select, :order).distinct.count(scope.klass.primary_key)
  end

  def self.print_audit_counts(counts)
    positive_counts = counts.select { |_name, count| count.positive? }

    if positive_counts.empty?
      puts "none"
    else
      positive_counts.each { |name, count| puts "#{name}: #{count}" }
    end
  end
end
