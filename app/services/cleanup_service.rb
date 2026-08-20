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
    # A missing comment event is not proof that the comment is orphaned. Some
    # live comments need their event reconstructed, while comments whose real
    # polymorphic parent is gone can be deleted safely.
    "Comment.missing_parent" => :comments_missing_parent,
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

    return audit if Rails.env.test?

    puts "Dangling records:"
    print_audit_counts(audit[:dangling_records])
    puts "Orphan PaperTrail versions:"
    print_audit_counts(audit[:orphan_versions])

    audit
  end

  def self.delete_orphan_records
    dangling_record_scopes.each do |label, scope|
      count = destroy_records(scope)
      puts "destroyed #{count} dangling #{label} records" unless Rails.env.test?
    end

    delete_orphan_versions
  end

  def self.orphan_record_audit
    {
      dangling_records: dangling_record_scopes.transform_values { |scope| unique_count(scope) },
      orphan_versions: orphan_version_scopes.transform_values(&:count)
    }
  end

  # These categories need more than the original destroy-in-scope loop: some
  # records must be repaired, some deleted in dependency order, and topic trees
  # rebuilt afterward. Keep this report side-effect free so operators can review
  # the complete plan before running any cleanup.
  def self.reference_integrity_audit
    missing_parent_events = events_missing_parent
    invalid_root_events = events_invalid_root
    affected_topic_ids = (
      events_missing_stance.where.not(topic_id: nil).distinct.pluck(:topic_id) +
      missing_parent_events.where.not(topic_id: nil).distinct.pluck(:topic_id) +
      invalid_root_events.distinct.pluck(:topic_id) +
      Event.where(eventable_type: "Comment", eventable_id: comments_missing_parent.select(:id))
           .where.not(topic_id: nil)
           .distinct
           .pluck(:topic_id)
    ).uniq

    {
      comments_missing_event: unique_count(comments_missing_event),
      comments_missing_event_with_existing_parent: unique_count(
        comments_missing_event.where.not(id: comments_missing_parent.select(:id))
      ),
      comments_missing_parent: unique_count(comments_missing_parent),
      events_missing_stance: unique_count(events_missing_stance),
      events_missing_parent: unique_count(missing_parent_events),
      events_invalid_root: unique_count(invalid_root_events),
      events_referencing_missing_topic: unique_count(events_missing_topic),
      notifications_missing_event_or_user: unique_count(notifications_missing_event_or_user),
      reactions_missing_stance: unique_count(reactions_missing_stance),
      tasks_users_missing_task: unique_count(tasks_users_missing_task),
      translations_missing_stance: unique_count(translations_missing_stance),
      versions_missing_stance: orphan_version_scope_for("Stance").count,
      search_documents_missing_stance: unique_count(search_documents_missing_stance),
      attachments_missing_stance: unique_count(attachments_missing_stance),
      announcement_missing_stance_ids: announcement_missing_stance_ids_count,
      announcements_with_missing_stance_ids: announcements_with_missing_stance_ids_count,
      topics_affected: affected_topic_ids.length,
      topic_ids_sample: affected_topic_ids.sort.first(20)
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
      .joins("LEFT JOIN outcomes parent_outcomes ON comments.parent_type = 'Outcome' AND parent_outcomes.id = comments.parent_id")
      .joins("LEFT JOIN polls parent_polls ON comments.parent_type = 'Poll' AND parent_polls.id = comments.parent_id")
      .joins("LEFT JOIN stances parent_stances ON comments.parent_type = 'Stance' AND parent_stances.id = comments.parent_id")
      .where(<<~SQL.squish)
        (comments.parent_type = 'Discussion' AND parent_discussions.id IS NULL) OR
        (comments.parent_type = 'Comment' AND parent_comments.id IS NULL) OR
        (comments.parent_type = 'Outcome' AND parent_outcomes.id IS NULL) OR
        (comments.parent_type = 'Poll' AND parent_polls.id IS NULL) OR
        (comments.parent_type = 'Stance' AND parent_stances.id IS NULL)
      SQL
  end

  def self.events_missing_topic
    Event
      .joins('LEFT JOIN topics ON events.topic_id = topics.id')
      .where('events.topic_id IS NOT NULL AND topics.id IS NULL')
  end

  def self.events_missing_stance
    Event
      .joins("LEFT JOIN stances ON events.eventable_type = 'Stance' AND stances.id = events.eventable_id")
      .where(eventable_type: "Stance", stances: { id: nil })
  end

  def self.events_missing_parent
    Event
      .joins("LEFT JOIN events parent_events ON parent_events.id = events.parent_id")
      .where.not(parent_id: nil)
      .where(parent_events: { id: nil })
  end

  def self.events_invalid_root
    Event
      .where.not(topic_id: nil)
      .where(parent_id: nil)
      .where.not(kind: %w[new_discussion poll_created])
  end

  def self.notifications_missing_event_or_user
    Notification
      .joins('LEFT JOIN events e ON notifications.event_id = e.id LEFT JOIN users u ON u.id = notifications.user_id')
      .where('e.id IS NULL OR u.id IS NULL')
  end

  def self.reactions_missing_stance
    Reaction
      .joins("LEFT JOIN stances ON reactions.reactable_type = 'Stance' AND stances.id = reactions.reactable_id")
      .where(reactable_type: "Stance", stances: { id: nil })
  end

  def self.tasks_users_missing_task
    TasksUser
      .joins("LEFT JOIN tasks ON tasks.id = tasks_users.task_id")
      .where(tasks: { id: nil })
  end

  def self.translations_missing_stance
    Translation
      .joins("LEFT JOIN stances ON translations.translatable_type = 'Stance' AND stances.id = translations.translatable_id")
      .where(translatable_type: "Stance", stances: { id: nil })
  end

  def self.search_documents_missing_stance
    PgSearch::Document
      .joins("LEFT JOIN stances ON pg_search_documents.searchable_type = 'Stance' AND stances.id = pg_search_documents.searchable_id")
      .where(searchable_type: "Stance", stances: { id: nil })
  end

  def self.attachments_missing_stance
    ActiveStorage::Attachment
      .joins("LEFT JOIN stances ON active_storage_attachments.record_type = 'Stance' AND stances.id = active_storage_attachments.record_id")
      .where(record_type: "Stance", stances: { id: nil })
  end

  def self.announcement_missing_stance_ids_count
    ActiveRecord::Base.connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM events
      CROSS JOIN LATERAL jsonb_array_elements_text(
        COALESCE(events.custom_fields -> 'stance_ids', '[]'::jsonb)
      ) stance_id
      LEFT JOIN stances ON stances.id = stance_id::bigint
      WHERE stances.id IS NULL
    SQL
  end

  def self.announcements_with_missing_stance_ids_count
    ActiveRecord::Base.connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(DISTINCT events.id)
      FROM events
      CROSS JOIN LATERAL jsonb_array_elements_text(
        COALESCE(events.custom_fields -> 'stance_ids', '[]'::jsonb)
      ) stance_id
      LEFT JOIN stances ON stances.id = stance_id::bigint
      WHERE stances.id IS NULL
    SQL
  end

  def self.subscriptions_missing_group
    Subscription
      .joins('LEFT JOIN groups ON subscriptions.id = groups.subscription_id')
      .where('groups.id IS NULL')
  end

  def self.delete_orphan_versions
    orphan_version_scopes.sum do |item_type, scope|
      count = scope.delete_all

      puts "deleted #{count} orphan #{item_type} version records" unless Rails.env.test?
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

    puts "Deleted #{user_ids.size} orphan users" unless Rails.env.test?
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
