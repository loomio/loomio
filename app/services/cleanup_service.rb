# Lifecycle maintenance for groups and inactive accounts, and read-only
# checks for relationships PostgreSQL cannot enforce with a foreign key.
module CleanupService
  UNUSED_GROUP_DISCARD_LIMIT = 1_000
  INACTIVE_ORPHAN_USER_LIMIT = 1_000
  INACTIVE_ORPHAN_USER_RETENTION = 90.days
  EMPTY_GROUP_SUBSCRIPTION_PLANS = %w[free trial].freeze
  EMPTY_GROUP_RETENTION = 60.days
  EXPIRED_TRIAL_RETENTION = 60.days
  EXPIRED_TRIAL_CATCH_UP_AGE = EXPIRED_TRIAL_RETENTION + 1.day
  EXPIRED_TRIAL_WARNING_LIMIT = 100
  DISCARDED_GROUP_DESTRUCTION_LIMIT = 100

  USER_REFERENCES = {
    anonymous_poll_voters: %i[voter_id inviter_id],
    bookmarks: %i[user_id],
    chatbots: %i[author_id],
    comments: %i[user_id discarded_by],
    discussion_templates: %i[author_id discarded_by hider_id],
    discussions: %i[author_id discarded_by],
    email_suppressions: %i[cleared_by_id],
    group_follows: %i[user_id],
    topic_items: %i[user_id],
    groups: %i[creator_id],
    member_email_aliases: %i[user_id author_id],
    membership_requests: %i[requestor_id responder_id],
    memberships: %i[user_id inviter_id revoker_id],
    notifications: %i[actor_id],
    outcomes: %i[author_id],
    omniauth_identities: %i[user_id],
    poll_templates: %i[author_id discarded_by hider_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
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
    "NotificationDelivery" => %i[recipient_type recipient_id],
    "TopicItem" => %i[itemable_type itemable_id],
    "PgSearch::Document" => %i[searchable_type searchable_id],
    "Reaction" => %i[reactable_type reactable_id],
    "Tagging" => %i[taggable_type taggable_id],
    "Task" => %i[record_type record_id],
    "Topic" => %i[topicable_type topicable_id],
    "Translation" => %i[translatable_type translatable_id]
  }.freeze

  # Keep references to retired models visible as legacy records. In particular,
  # a retired Document attachment can still identify a blob used elsewhere.
  POLYMORPHIC_TYPES_RETIRED = {
    "ActiveStorage::Attachment" => %w[Document]
  }.freeze

  DANGLING_RECORD_SCOPES = {
    "Comment.missing_event" => :comments_missing_event,
    "Comment.missing_parent" => :comments_missing_parent,
    "TopicItem.missing_stance" => :events_missing_stance,
    "TopicItem.missing_version" => :events_missing_version,
    "TopicItem.invalid_root" => :events_invalid_root,
    "Reaction.missing_stance" => :reactions_missing_stance,
    "Bookmark.missing_stance" => :bookmarks_missing_stance,
    "Task.missing_stance" => :tasks_missing_stance,
    "Translation.missing_stance" => :translations_missing_stance,
    "PgSearch::Document.missing_stance" => :search_documents_missing_stance,
    "ActiveStorage::Attachment.missing_stance" => :attachments_missing_stance
  }.freeze

  # Delete accounts outside the retention period only when they have no
  # durable association with the application. Administrators are always kept;
  # their removal requires an explicit administrative action.
  def self.delete_inactive_orphan_users(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago)
    user_ids = inactive_orphan_user_ids(inactive_before: inactive_before)

    return if user_ids.empty?

    count = 0
    user_ids.each do |id|
      with_write_lock(USER_REFERENCES.keys + %i[users sessions login_tokens push_subscriptions notification_deliveries notifications active_storage_attachments versions pg_search_documents]) do
        user = inactive_orphan_users(inactive_before: inactive_before).where(id: id).first
        next unless user

        PaperTrail::Version.where(item_type: "User", item_id: user.id).delete_all
        PgSearch::Document.where(author_id: user.id).delete_all
        PaperTrail.request(enabled: false) { user.destroy! }
        count += 1
      end
    end

    puts "Deleted #{count} inactive orphan users" if count.positive? && !Rails.env.test?
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

  # ID mode supports before/after checks in rehearsals where writes can be
  # isolated. Counts are the default for production inventory.
  def self.audit_orphan_records(include_ids: false)
    audit = {
      dangling_records: dangling_record_scopes,
      missing_polymorphic_targets: {},
      retired_polymorphic_types: {},
      unresolved_polymorphic_types: {},
      retained_records: { "Subscription.missing_group" => subscriptions_missing_group }
    }

    polymorphic_reference_scopes.each do |key, (category, scope)|
      audit.fetch(category)[key] = scope
    end

    audit.transform_values do |scopes|
      scopes.transform_values do |scope|
        if include_ids
          primary_key = scope.klass.arel_table[scope.klass.primary_key]
          scope.reorder(primary_key).distinct.pluck(primary_key)
        else
          unique_count(scope)
        end
      end
    end
  end

  # Timeline-specific diagnostics used to determine which topics need repair.
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

  def self.events_missing_version
    missing_reference(
      TopicItem.where.not(itemable_version_id: nil),
      :itemable_version_id,
      PaperTrail::Version
    )
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

  def self.polymorphic_reference_scopes
    POLYMORPHIC_REFERENCES.merge("PaperTrail::Version" => %i[item_type item_id]).each_with_object({}) do |(class_name, (type_column, id_column)), scopes|
      record_class = class_name.constantize

      record_class.distinct.pluck(type_column).compact.each do |record_type|
        scope = record_class.where(type_column => record_type)
        target = polymorphic_target_class(record_type)
        category = if POLYMORPHIC_TYPES_RETIRED.fetch(class_name, []).include?(record_type)
          :retired_polymorphic_types
        elsif target.nil?
          :unresolved_polymorphic_types
        else
          scope = missing_reference(scope, id_column, target)
          record_class == PaperTrail::Version ? :retained_records : :missing_polymorphic_targets
        end
        scopes["#{class_name}.#{record_type}"] = [category, scope]
      end
    end
  end

  def self.missing_reference(scope, id_column, target)
    source = scope.klass
    source_table = source.quoted_table_name
    target_table = target.quoted_table_name
    source_id = source.connection.quote_column_name(id_column)
    target_id = target.connection.quote_column_name(target.primary_key)

    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM #{target_table} AS reference_target
        WHERE reference_target.#{target_id} = #{source_table}.#{source_id}
      )
    SQL
  end

  def self.polymorphic_target_class(record_type)
    target_class = record_type.safe_constantize
    return unless target_class.is_a?(Class) && target_class < ActiveRecord::Base
    return unless target_class.table_exists? && target_class.primary_key

    target_class
  end

  def self.unique_count(scope)
    scope.unscope(:select, :order).distinct.count(scope.klass.primary_key)
  end

  def self.audit_empty_groups(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    validate_empty_group_plan!(plan: plan, limit: limit)
    trees = group_cleanup_trees(plan: plan, before: before, only_unused: true)
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
    return { discarded_roots: 0 } if audit[:root_ids].empty?

    # Recheck the candidate trees while writes to their eligibility data are locked.
    with_write_lock(%i[groups subscriptions topics]) do
      trees = group_cleanup_trees(plan: plan, before: before, only_unused: true, root_ids: audit[:root_ids])
      Group.kept.where(id: trees.values.flatten).update_all(discarded_at: Time.current, discarded_by: nil)
      { discarded_roots: trees.size }
    end || { discarded_roots: 0 }
  end

  def self.discard_unused_groups_and_warn_expired_trials(now: Time.current)
    EMPTY_GROUP_SUBSCRIPTION_PLANS.each do |plan|
      discard_empty_groups!(plan: plan, before: now - EMPTY_GROUP_RETENTION, limit: UNUSED_GROUP_DISCARD_LIMIT)
    end
    warn_and_discard_expired_trial_groups(now: now, only_unused: false)
  end

  def self.warn_and_discard_expired_trial_groups(now: Time.current, only_unused: nil)
    groups = expired_trial_groups(now: now)
    unless only_unused.nil?
      trees = group_cleanup_trees(plan: :trial, before: now - EXPIRED_TRIAL_RETENTION, only_unused: only_unused)
      # Reserve the first places in each daily batch for newly eligible trials.
      recently_expired = Subscription.sanitize_sql_array([
        "CASE WHEN subscriptions.expires_at > ? THEN 0 ELSE 1 END", now - EXPIRED_TRIAL_CATCH_UP_AGE
      ])
      groups = groups.where(id: trees.keys).reorder(Arel.sql(recently_expired), "subscriptions.expires_at", :id)
    end
    group_ids = groups.limit(EXPIRED_TRIAL_WARNING_LIMIT).pluck(:id)
    options = only_unused.nil? ? {} : { only_unused: only_unused }
    group_ids.each do |group_id|
      WarnAndDiscardExpiredTrialGroupWorker.perform_later(group_id, **options)
    end
    { queued_groups: group_ids.size }
  end

  def self.deletable_discarded_groups(now: Time.current)
    delay_days = AppConfig.discarded_group_deletion_after_days
    return Group.none unless delay_days

    discarded_before = now - delay_days.days
    Group.discarded.parents_only.where(discarded_at: ..discarded_before).where(<<~SQL.squish, cutoff: discarded_before, now: now)
      NOT EXISTS (
        SELECT 1 FROM subscriptions s
        WHERE s.id = groups.subscription_id
          AND (s.chargify_subscription_id IS NOT NULL OR s.billing_service_subscription_id IS NOT NULL)
          AND s.state IN ('active', 'pending', 'past_due', 'on_hold')
          AND (s.expires_at IS NULL OR s.expires_at > :now)
      )
      AND NOT EXISTS (
        WITH RECURSIVE tree AS (
          SELECT id, discarded_at, subscription_id FROM groups child WHERE child.parent_id = groups.id
          UNION ALL
          SELECT child.id, child.discarded_at, child.subscription_id
          FROM tree JOIN groups child ON child.parent_id = tree.id
        )
        SELECT 1 FROM tree
        WHERE discarded_at IS NULL OR discarded_at > :cutoff
           OR (subscription_id IS NOT NULL AND subscription_id IS DISTINCT FROM groups.subscription_id)
      )
    SQL
  end

  def self.descendant_groups(root_id)
    Group.with_recursive(group_descendants: [
      Group.where(parent_id: root_id).select(:id),
      Group.joins("JOIN group_descendants ON groups.parent_id = group_descendants.id").select(:id)
    ]).where("groups.id IN (SELECT id FROM group_descendants)")
  end

  def self.destroy_discarded_groups(now: Time.current, root_ids: nil)
    return 0 unless DestroyGroupWorker.enabled?

    SolidQueue::Job.transaction do
      connection = SolidQueue::Job.connection
      next 0 unless connection.select_value("SELECT pg_try_advisory_xact_lock(hashtextextended('loomio_discarded_group_dispatch', 0))")

      pending = SolidQueue::Job.where(queue_name: "group_destruction", finished_at: nil)
      remaining = DISCARDED_GROUP_DESTRUCTION_LIMIT - pending.count
      next 0 unless remaining.positive?

      queued_ids = pending.where(class_name: DestroyGroupWorker.name).map { |job| job.arguments.fetch("arguments").first }
      groups = deletable_discarded_groups(now: now).where.not(id: queued_ids)
      groups = groups.where(id: root_ids) if root_ids
      groups.order(:discarded_at, :id).limit(remaining).count do |group|
        DestroyGroupWorker.perform_later(group.id, group.discarded_at.iso8601(6))
      end
    end
  end

  def self.expired_trial_groups(now: Time.current)
    Group.kept.parents_only.joins(:subscription)
         .where(subscriptions: { plan: "trial", expires_at: ..(now - EXPIRED_TRIAL_RETENTION) })
         .order("subscriptions.expires_at", :id)
  end

  def self.group_cleanup_trees(plan:, before:, only_unused:, root_ids: nil)
    plan = plan.to_s
    validate_empty_group_plan!(plan: plan)
    lifecycle_condition = case plan
    when "free" then "s.plan = 'free' AND g.created_at <= :before"
    when "trial" then "s.plan = 'trial' AND s.expires_at <= :before"
    end
    root_condition = root_ids.nil? ? "" : Group.sanitize_sql_array(["AND g.id IN (?)", root_ids])
    topic_operator = only_unused ? "NOT EXISTS" : "EXISTS"
    sql = Group.sanitize_sql_array([ <<~SQL, { before: before } ])
      WITH RECURSIVE roots AS (
        SELECT g.id, g.subscription_id FROM groups g
        JOIN subscriptions s ON s.id = g.subscription_id
        WHERE g.parent_id IS NULL AND g.discarded_at IS NULL
          AND #{lifecycle_condition} #{root_condition}
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
        AND #{topic_operator} (SELECT 1 FROM used_roots u WHERE u.root_id = t.root_id)
      ORDER BY t.root_id, t.group_id
    SQL
    Group.connection.select_all(sql).to_a.group_by { |row| row["root_id"] }
         .transform_values { |rows| rows.map { |row| row["group_id"] } }
  end

  def self.validate_empty_group_plan!(plan:, limit: nil)
    raise ArgumentError, "plan must be free or trial" unless EMPTY_GROUP_SUBSCRIPTION_PLANS.include?(plan.to_s)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0
  end
end
