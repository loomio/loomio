# CleanupService repairs records which are already outside application
# invariants. Its deletes must be callbackless and explicitly ordered: normal
# callbacks can publish events, enqueue work, update counters, or traverse a
# broken association graph. Application services and model callbacks remain
# responsible for normal record lifecycle behavior.
#
# The following audits are temporary and should be removed after the named
# foreign keys have been deployed and validated:
# - groups_missing_parent: groups.parent_id -> groups.id
# - memberships_missing_group: memberships.group_id -> groups.id
# - membership_requests_missing_group: membership_requests.group_id -> groups.id
# - discussions_missing_group and polls_missing_group: the topics.group_id key
#   plus cascading topicable lifecycle keys
# - poll_options_missing_poll: deployed poll_options.poll_id -> polls.id
# - stances_missing_poll: stances.poll_id -> polls.id
# - stance_choices_missing_stance: deployed stance_choices.stance_id -> stances.id
# - outcomes_missing_poll: outcomes.poll_id -> polls.id
# - topics_missing_group: topics.group_id -> groups.id
# - topic_readers_missing_topic_or_user: topic_readers.topic_id/user_id
# - events_missing_topic: events.topic_id -> topics.id
# - events_missing_parent: deployed events.parent_id -> events.id
# - notifications_missing_event_or_user: deployed notifications.event_id/user_id
# - tasks_users_missing_task_or_user: deployed tasks_users.task_id/user_id keys
#
# These checks remain necessary because an ordinary foreign key cannot enforce
# them: polymorphic comment parents and eventables; polymorphic reactions,
# bookmarks, tasks, translations, search documents and attachments; comments
# whose inverse timeline event is missing; invalid topic event roots; orphan
# PaperTrail versions; and subscriptions which are no longer used by a group.
module CleanupService
  DELETE_BATCH_SIZE = 1_000

  POLYMORPHIC_REFERENCES = {
    "ActiveStorage::Attachment" => %i[record_type record_id],
    "Bookmark" => %i[bookmarkable_type bookmarkable_id],
    "Comment" => %i[parent_type parent_id],
    "Event" => %i[eventable_type eventable_id],
    "PgSearch::Document" => %i[searchable_type searchable_id],
    "Reaction" => %i[reactable_type reactable_id],
    "Tagging" => %i[taggable_type taggable_id],
    "Task" => %i[record_type record_id],
    "Topic" => %i[topicable_type topicable_id],
    "Translation" => %i[translatable_type translatable_id]
  }.freeze

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
    "Comment.missing_parent" => :comments_missing_parent,
    "Event.missing_stance" => :events_missing_stance,
    "Event.missing_topic" => :events_missing_topic,
    "Notification.missing_event_or_user" => :notifications_missing_event_or_user,
    "Reaction.missing_stance" => :reactions_missing_stance,
    "Bookmark.missing_stance" => :bookmarks_missing_stance,
    "Task.missing_stance" => :tasks_missing_stance,
    "TasksUser.missing_task_or_user" => :tasks_users_missing_task_or_user,
    "Translation.missing_stance" => :translations_missing_stance,
    "PgSearch::Document.missing_stance" => :search_documents_missing_stance,
    "ActiveStorage::Attachment.missing_stance" => :attachments_missing_stance,
    "Subscription.missing_group" => :subscriptions_missing_group
  }.freeze

  def self.audit_orphan_records
    audit = orphan_record_audit

    return audit if Rails.env.test?

    puts "Dangling records:"
    print_audit_counts(audit[:dangling_records])
    puts "Unresolved polymorphic types (not deleted):"
    print_audit_counts(audit[:unresolved_polymorphic_types])

    audit
  end

  def self.delete_orphan_records
    loop do
      count = dangling_record_scopes.sum do |label, scope|
        next 0 if scope.klass == Comment

        deleted = delete_records(scope)
        puts "deleted #{deleted} dangling #{label} records" unless Rails.env.test?
        deleted
      end
      count += delete_orphan_comments
      count += delete_orphan_polymorphic_records
      break if count.zero?
    end

    cleanup_event_parent_references!
    delete_orphan_versions
  end

  def self.orphan_record_audit
    {
      dangling_records: dangling_record_scopes.transform_values { |scope| unique_count(scope) },
      unresolved_polymorphic_types: unresolved_polymorphic_type_counts
    }
  end

  # These categories need more than the original destroy-in-scope loop: some
  # records must be repaired and some deleted in dependency order. Keep this
  # report side-effect free so operators can review the complete plan first.
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
      bookmarks_missing_stance: unique_count(bookmarks_missing_stance),
      tasks_missing_stance: unique_count(tasks_missing_stance),
      tasks_users_missing_task_or_user: unique_count(tasks_users_missing_task_or_user),
      translations_missing_stance: unique_count(translations_missing_stance),
      search_documents_missing_stance: unique_count(search_documents_missing_stance),
      attachments_missing_stance: unique_count(attachments_missing_stance),
      topics_affected: affected_topic_ids.length,
      topic_ids_sample: affected_topic_ids.sort.first(20)
    }
  end

  def self.cleanup_event_parent_references!
    Event.transaction do
      events_missing_parent.find_each do |event|
        if event.topic_id
          parent = event.find_parent_event
          raise "Event #{event.id} has no valid parent" unless parent&.topic_id == event.topic_id

          event.update_columns(parent_id: parent.id, depth: parent.depth + 1)
        elsif event.eventable
          event.update_columns(parent_id: nil, depth: 0)
        else
          Event.where(id: event.id).delete_all
        end
      end

      events_invalid_root.find_each do |event|
        parent = event.find_parent_event
        raise "Event #{event.id} has no valid parent" unless parent&.topic_id == event.topic_id

        event.update_columns(parent_id: parent.id, depth: parent.depth + 1)
      end
    end
  end

  # Delete comments which could not have appeared in a topic because either
  # their polymorphic parent or their timeline event is gone. Repeat because
  # deleting one such comment can expose its replies as another orphan layer.
  def self.cleanup_comment_references!
    Comment.transaction do
      delete_orphan_comments
      delete_orphan_polymorphic_records
      cleanup_event_parent_references!
    end
  end

  def self.delete_orphan_comments
    count = 0

    loop do
      ids = (
        comments_missing_parent.limit(1_000).pluck(:id) +
        comments_missing_event.limit(1_000).pluck(:id)
      ).uniq
      break if ids.empty?

      count += Comment.where(id: ids).delete_all
    end

    puts "deleted #{count} dangling Comment records" unless Rails.env.test?
    count
  end

  def self.dangling_record_scopes
    DANGLING_RECORD_SCOPES.transform_values { |method_name| public_send(method_name) }
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

  def self.bookmarks_missing_stance
    Bookmark
      .joins("LEFT JOIN stances ON bookmarks.bookmarkable_type = 'Stance' AND stances.id = bookmarks.bookmarkable_id")
      .where(bookmarkable_type: "Stance", stances: { id: nil })
  end

  def self.tasks_missing_stance
    Task
      .joins("LEFT JOIN stances ON tasks.record_type = 'Stance' AND stances.id = tasks.record_id")
      .where(record_type: "Stance", stances: { id: nil })
  end

  def self.tasks_users_missing_task_or_user
    TasksUser
      .joins("LEFT JOIN tasks ON tasks.id = tasks_users.task_id LEFT JOIN users ON users.id = tasks_users.user_id")
      .where("tasks.id IS NULL OR users.id IS NULL")
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

  def self.delete_records(scope)
    record_class = scope.klass
    primary_key = record_class.primary_key
    primary_key_column = record_class.arel_table[primary_key]
    count = 0

    loop do
      ids = scope.limit(DELETE_BATCH_SIZE).pluck(primary_key_column)
      break if ids.empty?

      count += record_class.where(primary_key => ids).delete_all
    end

    count
  end

  def self.delete_orphan_polymorphic_records
    POLYMORPHIC_REFERENCES.sum do |class_name, (type_column, id_column)|
      record_class = class_name.constantize

      record_class.distinct.pluck(type_column).compact.sum do |record_type|
        count = delete_records(
          orphan_polymorphic_scope(
            record_class,
            type_column,
            id_column,
            record_type
          )
        )
        puts "deleted #{count} orphan #{class_name} #{record_type} records" unless Rails.env.test?
        count
      end
    end
  end

  def self.orphan_polymorphic_scope(record_class, type_column, id_column, record_type)
    target_class = polymorphic_target_class(record_type)
    scope = record_class.where(type_column => record_type)

    return scope.none unless target_class

    record_table = record_class.quoted_table_name
    target_table = target_class.quoted_table_name
    record_id = record_class.connection.quote_column_name(id_column)
    target_id = target_class.connection.quote_column_name(target_class.primary_key)

    scope.where("NOT EXISTS (SELECT 1 FROM #{target_table} WHERE #{target_table}.#{target_id} = #{record_table}.#{record_id})")
  end

  def self.unresolved_polymorphic_type_counts
    POLYMORPHIC_REFERENCES.each_with_object({}) do |(class_name, (type_column, _id_column)), counts|
      record_class = class_name.constantize

      record_class.group(type_column).count.each do |record_type, count|
        next if record_type.blank? || polymorphic_target_class(record_type)

        counts["#{class_name}.#{record_type}"] = count
      end
    end
  end

  def self.polymorphic_target_class(record_type)
    target_class = record_type.safe_constantize
    return unless target_class.is_a?(Class) && target_class < ActiveRecord::Base
    return unless target_class.table_exists? && target_class.primary_key

    target_class
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
