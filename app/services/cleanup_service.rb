# CleanupService removes records which are no longer needed. Integrity cleanup
# repairs or deletes records outside application invariants, using callbackless
# deletes in an explicit order so it can safely traverse broken association
# graphs. Inactive orphan users are valid lifecycle records, so their removal
# uses normal model destruction instead.
#
# Ordinary parent references are protected by validated foreign keys and required
# columns. Deploy the reference-integrity migrations before running this version.
#
# These checks remain necessary because an ordinary foreign key cannot enforce
# them: polymorphic comment parents and itemables; polymorphic reactions,
# bookmarks, tasks, translations, search documents and attachments; comments
# whose inverse timeline topic_item is missing; invalid topic topic_item roots; orphan
# PaperTrail versions; retired polymorphic types left by removed models; and
# subscriptions which are no longer used by a group.
module CleanupService
  DELETE_BATCH_SIZE = 1_000
  DELETE_PASS_LIMIT = 3
  INACTIVE_ORPHAN_USER_LIMIT = 1_000
  INACTIVE_ORPHAN_USER_RETENTION = 60.days
  EMPTY_GROUP_SUBSCRIPTION_PLANS = %w[free trial].freeze
  EMPTY_GROUP_RETENTION = 60.days
  EXPIRED_TRIAL_RETENTION = 60.days
  EXPIRED_TRIAL_WARNING_LIMIT = 100
  DISCARDED_GROUP_DESTRUCTION_LIMIT = 100

  USER_REFERENCES = {
    bookmarks: %i[user_id],
    chatbots: %i[author_id],
    comments: %i[user_id discarded_by],
    demos: %i[author_id],
    discussion_templates: %i[author_id discarded_by],
    discussions: %i[author_id discarded_by],
    topic_items: %i[user_id],
    groups: %i[creator_id],
    member_email_aliases: %i[user_id author_id],
    membership_requests: %i[requestor_id responder_id],
    memberships: %i[user_id inviter_id revoker_id],
    notifications: %i[actor_id],
    outcomes: %i[author_id],
    omniauth_identities: %i[user_id],
    poll_templates: %i[author_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
    stance_receipts: %i[voter_id inviter_id],
    stances: %i[participant_id inviter_id revoker_id redactor_id],
    subscriptions: %i[owner_id],
    tasks: %i[author_id doer_id],
    tasks_users: %i[user_id],
    topic_readers: %i[user_id inviter_id revoker_id],
    topics: %i[locker_id discarded_by],
    users: %i[deactivator_id]
  }.freeze

  # Legacy associations lack foreign keys, so row locks alone cannot exclude
  # new references during destructive eligibility checks. Keep these sections
  # short: skip locks held by existing writers, and release promptly so new
  # writers can proceed. These locks are for maintenance, not request paths.
  def self.with_write_lock(tables)
    ActiveRecord::Base.transaction(requires_new: true) do
      names = tables.map(&:to_s).uniq.sort.map { |table| ActiveRecord::Base.connection.quote_table_name(table) }
      begin
        ActiveRecord::Base.connection.execute("LOCK TABLE #{names.join(', ')} IN SHARE ROW EXCLUSIVE MODE NOWAIT")
      rescue ActiveRecord::LockWaitTimeout => error
        Rails.logger.info("Cleanup deferred: #{error.message}")
        raise ActiveRecord::Rollback
      end
      yield
    end
  end

  POLYMORPHIC_REFERENCES = {
    "ActiveStorage::Attachment" => %i[record_type record_id],
    "Bookmark" => %i[bookmarkable_type bookmarkable_id],
    "Comment" => %i[parent_type parent_id],
    "Notification" => %i[subject_type subject_id],
    "TopicItem" => %i[itemable_type itemable_id],
    "PgSearch::Document" => %i[searchable_type searchable_id],
    "Reaction" => %i[reactable_type reactable_id],
    "Tagging" => %i[taggable_type taggable_id],
    "Task" => %i[record_type record_id],
    "Topic" => %i[topicable_type topicable_id],
    "Translation" => %i[translatable_type translatable_id]
  }.freeze

  # These models and their tables have been removed. Their polymorphic rows
  # cannot refer to a live application record and are safe to delete. Deleting
  # a legacy Document attachment must not purge its blob because the document
  # migration may have attached that same blob to its current parent record.
  POLYMORPHIC_TYPES_RETIRED = {
    "ActiveStorage::Attachment" => %w[Document]
  }.freeze

  DANGLING_RECORD_SCOPES = {
    "Comment.missing_event" => :comments_missing_event,
    "Comment.missing_parent" => :comments_missing_parent,
    "TopicItem.missing_stance" => :events_missing_stance,
    "Reaction.missing_stance" => :reactions_missing_stance,
    "Bookmark.missing_stance" => :bookmarks_missing_stance,
    "Task.missing_stance" => :tasks_missing_stance,
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
    puts "Retired polymorphic types (will be deleted):"
    print_audit_counts(audit[:retired_polymorphic_types])
    puts "Unresolved polymorphic types (not deleted):"
    print_audit_counts(audit[:unresolved_polymorphic_types])

    audit
  end

  def self.delete_orphan_records
    # A few bounded passes resolve dependencies exposed by earlier deletions
    # without turning an accumulated backlog into an unbounded maintenance job.
    DELETE_PASS_LIMIT.times do
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

  # Delete accounts outside the retention period only when they have no
  # durable association with the application. Administrators are always kept;
  # their removal requires an explicit administrative action.
  def self.delete_inactive_orphan_users
    user_ids = inactive_orphan_user_ids

    if user_ids.empty?
      puts "No inactive orphan users to delete"
      return
    end

    count = 0
    user_ids.each do |id|
      with_write_lock(USER_REFERENCES.keys + %i[users sessions login_tokens push_subscriptions notification_deliveries notifications active_storage_attachments versions pg_search_documents]) do
        user = inactive_orphan_users.where(id: id).first
        next unless user

        PaperTrail::Version.where(item_type: "User", item_id: user.id).delete_all
        PgSearch::Document.where(author_id: user.id).delete_all
        PaperTrail.request(enabled: false) { user.destroy! }
        count += 1
      end
    end

    puts "Deleted #{count} inactive orphan users" unless Rails.env.test?
  end

  def self.inactive_orphan_user_ids(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago, limit: INACTIVE_ORPHAN_USER_LIMIT)
    inactive_orphan_users(inactive_before: inactive_before).order(:id).limit(limit).pluck(:id)
  end

  def self.inactive_orphan_users(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago)
    inactive_users = User.where(is_admin: false).where(
      "GREATEST(created_at, current_sign_in_at, last_sign_in_at, last_seen_at) < :cutoff",
      cutoff: inactive_before
    )
    scope = USER_REFERENCES.reduce(inactive_users) do |scope, (table, columns)|
      columns.reduce(scope) do |column_scope, column|
        column_scope.where("NOT EXISTS (SELECT 1 FROM #{table} cleanup_references WHERE cleanup_references.#{column} = users.id)")
      end
    end
    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM notification_deliveries
        WHERE notification_deliveries.recipient_type = 'User'
          AND notification_deliveries.recipient_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM active_storage_attachments
        WHERE record_type = 'User' AND record_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM notifications
        WHERE recipient_user_ids @> ARRAY[users.id]::integer[]
      )
    SQL
  end

  def self.orphan_record_audit
    {
      dangling_records: dangling_record_scopes.transform_values { |scope| unique_count(scope) },
      retired_polymorphic_types: retired_polymorphic_type_counts,
      unresolved_polymorphic_types: unresolved_polymorphic_type_counts
    }
  end

  # These categories need more than the original destroy-in-scope loop: some
  # records must be repaired and some deleted in dependency order. Keep this
  # report side-effect free so operators can review the complete plan first.
  def self.reference_integrity_audit
    invalid_root_topic_items = events_invalid_root
    affected_topic_ids = (
      events_missing_stance.where.not(topic_id: nil).distinct.pluck(:topic_id) +
      invalid_root_topic_items.distinct.pluck(:topic_id) +
      TopicItem.where(itemable_type: "Comment", itemable_id: comments_missing_parent.select(:id))
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
      events_invalid_root: unique_count(invalid_root_topic_items),
      reactions_missing_stance: unique_count(reactions_missing_stance),
      bookmarks_missing_stance: unique_count(bookmarks_missing_stance),
      tasks_missing_stance: unique_count(tasks_missing_stance),
      translations_missing_stance: unique_count(translations_missing_stance),
      search_documents_missing_stance: unique_count(search_documents_missing_stance),
      attachments_missing_stance: unique_count(attachments_missing_stance),
      topics_affected: affected_topic_ids.length,
      topic_ids_sample: affected_topic_ids.sort.first(20)
    }
  end

  def self.cleanup_event_parent_references!
    TopicItem.transaction do
      events_invalid_root.limit(DELETE_BATCH_SIZE).find_each do |topic_item|
        parent = topic_item.find_parent_topic_item
        raise "TopicItem #{topic_item.id} has no valid parent" unless parent&.topic_id == topic_item.topic_id

        topic_item.update_columns(parent_id: parent.id, depth: parent.depth + 1)
      end
    end
  end

  # Missing timeline entries and broken hierarchy links are repairable data,
  # not proof that content is disposable. Keep them in the audit for repair.
  def self.cleanup_comment_references!
    Comment.transaction do
      delete_orphan_comments
      delete_orphan_polymorphic_records
      cleanup_event_parent_references!
    end
  end

  def self.delete_orphan_comments
    count = delete_records(comments_missing_parent)
    puts "deleted #{count} dangling Comment records" unless Rails.env.test?
    count
  end

  def self.dangling_record_scopes
    DANGLING_RECORD_SCOPES.transform_values { |method_name| public_send(method_name) }
  end

  def self.comments_missing_event
    Comment
      .joins("LEFT JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id")
      .where('topic_items.id IS NULL')
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

  def self.events_missing_stance
    TopicItem
      .joins("LEFT JOIN stances ON topic_items.itemable_type = 'Stance' AND stances.id = topic_items.itemable_id")
      .where(itemable_type: "Stance", stances: { id: nil })
  end

  def self.events_invalid_root
    TopicItem
      .where.not(topic_id: nil)
      .where(parent_id: nil)
      .where.not(kind: %w[new_discussion poll_created])
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
      count = delete_records(scope)

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
    # A missing parent group says nothing about the value of its subtree.
    return 0 if record_class == Group
    if record_class == Comment
      scope = scope.where(id: comments_missing_parent.select(:id)).where(<<~SQL.squish)
        NOT EXISTS (
          SELECT 1 FROM topic_items
          JOIN topics ON topics.id = topic_items.topic_id
          WHERE topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id
        )
        AND NOT EXISTS (
          SELECT 1 FROM comments children
          WHERE children.parent_type = 'Comment' AND children.parent_id = comments.id
        )
      SQL
    end
    if record_class == TopicItem
      # Raw deletes bypass reparenting callbacks, and the self-FK cascades.
      # Preserve damaged ancestors until their surviving children are repaired.
      scope = scope.where("NOT EXISTS (SELECT 1 FROM topic_items children WHERE children.parent_id = topic_items.id)")
    end
    if record_class == Topic
      # A missing polymorphic root does not make surviving content disposable.
      # Keep the topic for repair; its FKs also prevent concurrent child inserts
      # from being orphaned if an otherwise empty topic is deleted here.
      %w[topic_items polls discussions].each do |table|
        scope = scope.where("NOT EXISTS (SELECT 1 FROM #{table} children WHERE children.topic_id = topics.id)")
      end
    end
    primary_key = record_class.primary_key
    primary_key_column = record_class.arel_table[primary_key]
    ids = scope.limit(DELETE_BATCH_SIZE).pluck(primary_key_column)
    return 0 if ids.empty?

    deleted = if record_class == Comment
      with_write_lock(%i[comments topic_items topics discussions polls stances outcomes]) { scope.where(primary_key => ids).delete_all }
    elsif record_class == TopicItem
      with_write_lock(%i[topic_items]) { scope.where(primary_key => ids).delete_all }
    else
      scope.where(primary_key => ids).delete_all
    end
    deleted.to_i
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
    scope = record_class.where(type_column => record_type)
    return scope if polymorphic_type_retired?(record_class.name, record_type)

    target_class = polymorphic_target_class(record_type)

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
        next if record_type.blank?
        next if polymorphic_type_retired?(class_name, record_type)
        next if polymorphic_target_class(record_type)

        counts["#{class_name}.#{record_type}"] = count
      end
    end
  end

  def self.retired_polymorphic_type_counts
    POLYMORPHIC_TYPES_RETIRED.each_with_object({}) do |(class_name, record_types), counts|
      record_class = class_name.constantize
      type_column = POLYMORPHIC_REFERENCES.fetch(class_name).first

      record_types.each do |record_type|
        counts["#{class_name}.#{record_type}"] = record_class.where(type_column => record_type).count
      end
    end
  end

  def self.polymorphic_type_retired?(class_name, record_type)
    POLYMORPHIC_TYPES_RETIRED.fetch(class_name, []).include?(record_type)
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

  def self.audit_empty_groups(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    validate_empty_group_plan!(plan: plan, limit: limit)
    trees = empty_group_trees(plan: plan, before: before)
    trees = trees.first(limit).to_h if limit
    {
      plan: plan.to_s,
      before: before.iso8601,
      root_ids: trees.keys,
      group_ids: trees.values.flatten,
      trees: trees
    }
  end

  def self.discard_empty_groups!(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    audit = audit_empty_groups(plan: plan, before: before, limit: limit)

    # These dormant trees have already been selected by the audit query. A bulk
    # update keeps the manual cleanup practical and deliberately has no audit trail.
    Group.kept.where(id: audit[:group_ids]).update_all(discarded_at: Time.current, discarded_by: nil)

    { discarded_roots: audit[:root_ids].size }
  end

  def self.warn_and_discard_expired_trial_groups(now: Time.current)
    group_ids = expired_trial_groups(now: now).limit(EXPIRED_TRIAL_WARNING_LIMIT).pluck(:id)
    group_ids.each { |group_id| WarnAndDiscardExpiredTrialGroupWorker.perform_later(group_id) }
    { queued_groups: group_ids.size }
  end

  def self.destroy_discarded_groups(now: Time.current)
    discarded_before = now - AppConfig.group_deletion_delay_days.days
    groups = Group.discarded.parents_only.where(discarded_at: ..discarded_before)
                  .order(:discarded_at, :id)
                  .limit(DISCARDED_GROUP_DESTRUCTION_LIMIT)

    groups.find_each do |group|
      DestroyGroupWorker.perform_later(group.id, group.discarded_at.iso8601(6))
    end
  end

  def self.expired_trial_groups(now: Time.current)
    Group.kept.parents_only.joins(:subscription)
         .where(subscriptions: { plan: "trial", expires_at: ..(now - EXPIRED_TRIAL_RETENTION) })
         .order("subscriptions.expires_at", :id)
  end

  def self.empty_group_trees(plan:, before:)
    plan = plan.to_s
    validate_empty_group_plan!(plan: plan)
    lifecycle_condition = case plan
    when "free" then "s.plan = 'free' AND g.created_at <= :before"
    when "trial" then "s.plan = 'trial' AND s.expires_at <= :before"
    end
    sql = Group.sanitize_sql_array([ <<~SQL, { before: before } ])
      WITH RECURSIVE roots AS (
        SELECT g.id, g.subscription_id FROM groups g
        JOIN subscriptions s ON s.id = g.subscription_id
        WHERE g.parent_id IS NULL AND g.discarded_at IS NULL
          AND #{lifecycle_condition}
          AND s.chargify_subscription_id IS NULL AND s.billing_service_subscription_id IS NULL
          AND NOT EXISTS (SELECT 1 FROM groups other WHERE other.parent_id IS NULL
            AND other.subscription_id = s.id AND other.id != g.id)
      ), tree AS (
        SELECT id AS root_id, id AS group_id FROM roots
        UNION ALL
        SELECT t.root_id, g.id FROM tree t JOIN groups g ON g.parent_id = t.group_id
      ), used_roots AS (
        SELECT t.root_id FROM tree t JOIN topics ON topics.group_id = t.group_id
      ), excluded_roots AS (
        SELECT t.root_id FROM tree t JOIN groups g ON g.id = t.group_id
        JOIN roots r ON r.id = t.root_id
        WHERE g.id != r.id AND g.subscription_id IS NOT NULL AND g.subscription_id != r.subscription_id
      )
      SELECT t.root_id, t.group_id FROM tree t
      WHERE NOT EXISTS (SELECT 1 FROM excluded_roots e WHERE e.root_id = t.root_id)
        AND NOT EXISTS (SELECT 1 FROM used_roots u WHERE u.root_id = t.root_id)
      ORDER BY t.root_id, t.group_id
    SQL
    Group.connection.select_all(sql).to_a.group_by { |row| row["root_id"] }
         .transform_values { |rows| rows.map { |row| row["group_id"] } }
  end

  def self.validate_empty_group_plan!(plan:, limit: nil)
    raise ArgumentError, "plan must be free or trial" unless EMPTY_GROUP_SUBSCRIPTION_PLANS.include?(plan.to_s)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0
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
