# Cleanup of topic-free free and expired-trial group trees. Memberships,
# templates and uploads do not make a tree nonempty; any topic, including a
# discarded topic in a discarded descendant, does. Billing and conflicting
# subscription links exclude a tree.
module EmptyGroupCleanupService
  RETENTION_PERIOD = 60.days
  COHORTS = %w[free trial].freeze

  def self.audit(cohort:, before: RETENTION_PERIOD.ago, limit: nil)
    validate!(cohort: cohort, limit: limit)
    trees = candidate_trees(cohort: cohort, before: before)
    trees = trees.first(limit).to_h if limit
    {
      cohort: cohort.to_s,
      before: before.iso8601,
      root_ids: trees.keys,
      group_ids: trees.values.flatten,
      trees: trees
    }
  end

  # Fix and log the plan before deletion, recheck each complete tree, then use
  # normal destruction callbacks and their transaction, without explicit locks.
  # Flush each result so interrupted runs are auditable.
  def self.delete!(cohort:, io:, before: RETENTION_PERIOD.ago, limit: nil)
    plan = audit(cohort: cohort, before: before, limit: limit)
    log(io, type: "plan", at: Time.current.iso8601, **plan, counts: record_counts)
    result = { deleted_roots: 0, deleted_groups: 0, skipped_roots: 0 }

    plan[:root_ids].each do |root_id|
      tree = candidate_trees(cohort: cohort, before: before, root_id: root_id)[root_id]
      unless tree && tree == plan[:trees][root_id]
        result[:skipped_roots] += 1
        log(io, type: "skipped", root_id: root_id, reason: "no longer eligible or tree changed")
        next
      end

      log(io, type: "deleting", root_id: root_id, group_ids: tree)
      PaperTrail.request(enabled: false) { Group.find(root_id).destroy! }
      result[:deleted_roots] += 1
      result[:deleted_groups] += tree.size
      log(io, type: "deleted", at: Time.current.iso8601, root_id: root_id, group_ids: tree)
    end

    log(io, type: "complete", at: Time.current.iso8601, **result, counts: record_counts)
    result
  rescue StandardError => error
    log(io, type: "failed", at: Time.current.iso8601, error: error.class.name, message: error.message)
    raise
  end

  def self.candidate_trees(cohort:, before:, root_id: nil)
    trees(cohort: cohort, before: before, root_id: root_id, topic_free: true)
  end

  # The warning path uses this to apply the same billing and subscription-tree
  # exclusions to trials that contain topics.
  def self.eligible_trees(cohort:, before:, root_id: nil)
    trees(cohort: cohort, before: before, root_id: root_id, topic_free: false)
  end

  def self.trees(cohort:, before:, root_id:, topic_free:)
    cohort = cohort.to_s
    validate!(cohort: cohort)
    lifecycle_condition = case cohort
    when "free" then "s.plan = 'free' AND g.created_at <= :before"
    when "trial" then "s.plan = 'trial' AND s.expires_at <= :before"
    end
    sql = Group.sanitize_sql_array([ <<~SQL, { before: before, root_id: root_id, topic_free: topic_free } ])
      WITH RECURSIVE roots AS (
        SELECT g.id, g.subscription_id FROM groups g
        JOIN subscriptions s ON s.id = g.subscription_id
        WHERE g.parent_id IS NULL
          AND #{lifecycle_condition}
          AND s.chargify_subscription_id IS NULL AND s.billing_service_subscription_id IS NULL
          AND (:root_id IS NULL OR g.id = :root_id)
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
        AND (:topic_free = FALSE OR NOT EXISTS (SELECT 1 FROM used_roots u WHERE u.root_id = t.root_id))
      ORDER BY t.root_id, t.group_id
    SQL
    Group.connection.select_all(sql).to_a.group_by { |row| row["root_id"] }
         .transform_values { |rows| rows.map { |row| row["group_id"] } }
  end

  def self.validate!(cohort:, limit: nil)
    raise ArgumentError, "cohort must be free or trial" unless COHORTS.include?(cohort.to_s)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0
  end

  def self.record_counts
    {
      groups: Group.count,
      topics: Topic.count,
      discussions: Discussion.count,
      polls: Poll.count,
      comments: Comment.count,
      users: User.count,
      memberships: Membership.count
    }
  end

  def self.log(io, entry)
    io.puts(entry.to_json)
    io.flush
  end

  private_class_method :trees, :validate!, :record_counts, :log
end
