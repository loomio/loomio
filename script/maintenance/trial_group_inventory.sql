-- Inventory for manual review, not deletion eligibility.
-- Run seeded-content cleanup first; this query counts all remaining content.
-- Counts organisations recursively, including discarded descendants.
-- Run with psql -X -qAt -v ON_ERROR_STOP=1 -v as_of=2026-09-07
--   -d loomio_production -f script/maintenance/trial_group_inventory.sql
-- Redirect the JSON output outside the repository: it contains production IDs.
\set ON_ERROR_STOP on
\if :{?as_of}
\else
  \set as_of now
\endif

\if :{?seeded_cleanup_completed}
\else
  \set seeded_cleanup_completed false
\endif

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL statement_timeout = '120s';
SET LOCAL work_mem = '64MB';
SET LOCAL jit = off;

WITH RECURSIVE
parameters AS (
  SELECT :'as_of'::timestamp AS as_of
),
tree AS (
  SELECT id AS root_id, id AS group_id, ARRAY[id] AS path
  FROM groups WHERE parent_id IS NULL
  UNION ALL
  SELECT t.root_id, g.id, t.path || g.id
  FROM tree t JOIN groups g ON g.parent_id = t.group_id
  WHERE NOT g.id = ANY(t.path)
),
group_counts AS (
  SELECT t.root_id, count(*) AS groups_count,
         count(*) FILTER (WHERE g.discarded_at IS NOT NULL) AS discarded_groups_count,
         count(*) FILTER (
           WHERE g.id != t.root_id AND g.subscription_id IS NOT NULL
             AND g.subscription_id IS DISTINCT FROM root.subscription_id
         ) AS different_child_subscriptions_count,
         count(*) FILTER (
           WHERE g.logo_file_name IS NOT NULL OR g.cover_photo_file_name IS NOT NULL
             OR COALESCE(g.attachments, '[]'::jsonb) NOT IN ('[]'::jsonb, '{}'::jsonb, 'null'::jsonb)
         ) AS groups_with_legacy_uploads
  FROM tree t JOIN groups g ON g.id = t.group_id
  JOIN groups root ON root.id = t.root_id GROUP BY t.root_id
),
topic_counts AS (
  SELECT t.root_id, count(*) AS topics_count,
         count(*) FILTER (WHERE topics.discarded_at IS NOT NULL) AS discarded_topics_count,
         max(topics.last_activity_at) AS topic_activity_latest
  FROM tree t JOIN topics ON topics.group_id = t.group_id GROUP BY t.root_id
),
membership_counts AS (
  SELECT t.root_id, count(DISTINCT m.user_id) AS users_ever_count,
         count(DISTINCT m.user_id) FILTER (WHERE m.revoked_at IS NULL AND m.accepted_at IS NOT NULL) AS accepted_users_count,
         count(*) FILTER (WHERE m.revoked_at IS NOT NULL) AS revoked_memberships_count
  FROM tree t JOIN memberships m ON m.group_id = t.group_id GROUP BY t.root_id
),
-- These references prevent treating a topic-free organisation as empty.
other_references AS (
  SELECT group_id FROM discussion_templates
  UNION ALL SELECT group_id FROM poll_templates
  UNION ALL SELECT group_id FROM membership_requests
  UNION ALL SELECT group_id FROM chatbots
  UNION ALL SELECT group_id FROM tags
  UNION ALL SELECT group_id FROM received_emails
  UNION ALL SELECT group_id FROM group_surveys
  UNION ALL SELECT group_id FROM demos
  UNION ALL SELECT group_id FROM webhooks
  UNION ALL SELECT group_id FROM member_email_aliases
  UNION ALL SELECT group_id FROM group_handle_redirects
  UNION ALL SELECT group_id FROM active_storage_attachments
  UNION ALL SELECT record_id FROM active_storage_attachments WHERE record_type = 'Group'
),
reference_counts AS (
  SELECT t.root_id, count(*) AS other_references_count
  FROM tree t JOIN other_references r ON r.group_id = t.group_id GROUP BY t.root_id
),
subscription_sharing AS (
  SELECT subscription_id, count(*) AS subscription_roots_count
  FROM groups WHERE parent_id IS NULL AND subscription_id IS NOT NULL GROUP BY subscription_id
),
inventory AS (
  SELECT g.id AS root_id, g.created_at, g.discarded_at, g.subscription_id,
         s.plan, s.state, s.expires_at, s.payment_method,
         s.chargify_subscription_id IS NOT NULL OR s.billing_service_subscription_id IS NOT NULL AS has_billing_reference,
         CASE WHEN s.id IS NULL THEN 'missing'
              WHEN s.plan IN ('trial', 'free') THEN s.plan ELSE 'other' END AS plan_cohort,
         CASE WHEN s.expires_at IS NULL THEN 'no expiry'
              WHEN s.expires_at >= p.as_of THEN 'not expired'
              WHEN s.expires_at > p.as_of - interval '60 days' THEN 'under 60 days'
              WHEN s.expires_at > p.as_of - interval '1 year' THEN '60 days to 1 year'
              WHEN s.expires_at > p.as_of - interval '3 years' THEN '1 to 3 years'
              WHEN s.expires_at > p.as_of - interval '5 years' THEN '3 to 5 years'
              ELSE '5 years or more' END AS expiry_age,
         gc.groups_count, gc.discarded_groups_count, gc.different_child_subscriptions_count, gc.groups_with_legacy_uploads,
         COALESCE(ss.subscription_roots_count, 0) AS subscription_roots_count,
         COALESCE(tc.topics_count, 0) AS topics_count,
         COALESCE(tc.discarded_topics_count, 0) AS discarded_topics_count,
         tc.topic_activity_latest,
         COALESCE(mc.users_ever_count, 0) AS users_ever_count,
         COALESCE(mc.accepted_users_count, 0) AS accepted_users_count,
         COALESCE(mc.revoked_memberships_count, 0) AS revoked_memberships_count,
         COALESCE(rc.other_references_count, 0) AS other_references_count
  FROM groups g CROSS JOIN parameters p
  LEFT JOIN subscriptions s ON s.id = g.subscription_id
  JOIN group_counts gc ON gc.root_id = g.id
  LEFT JOIN topic_counts tc ON tc.root_id = g.id
  LEFT JOIN membership_counts mc ON mc.root_id = g.id
  LEFT JOIN reference_counts rc ON rc.root_id = g.id
  LEFT JOIN subscription_sharing ss ON ss.subscription_id = g.subscription_id
  WHERE g.parent_id IS NULL
),
cohorts AS (
  SELECT plan_cohort, state, discarded_at IS NOT NULL AS discarded, expiry_age,
         count(*) AS organisations, sum(groups_count) AS groups,
         sum(topics_count) AS topics,
         count(*) FILTER (WHERE topics_count = 0) AS organisations_without_topics,
         count(*) FILTER (
           WHERE topics_count = 0 AND users_ever_count < 2 AND revoked_memberships_count = 0
             AND other_references_count = 0 AND groups_with_legacy_uploads = 0
         ) AS organisations_without_recorded_use_signals,
         count(*) FILTER (WHERE has_billing_reference) AS organisations_with_billing_reference,
         count(*) FILTER (WHERE subscription_roots_count > 1 OR different_child_subscriptions_count > 0) AS organisations_with_subscription_links_to_review
  FROM inventory GROUP BY 1,2,3,4
)
SELECT jsonb_build_object(
  'database', current_database(),
  'as_of', (SELECT as_of FROM parameters),
  'generated_at', current_timestamp,
  'seeded_content_filtered_by_inventory', false,
  'seeded_cleanup_completed', :'seeded_cleanup_completed'::boolean,
  'notes', 'Baseline only: absence of these signals is not deletion approval. All remaining content and discarded topics are included; no seed filtering occurs in this query. Other references may be counted twice for group attachments. Topic activity is not necessarily human activity. Paid/free/trial labels and subscription links require review.',
  'groups_total', (SELECT count(*) FROM groups),
  'groups_not_reachable_from_root', (SELECT count(*) FROM groups) - (SELECT count(DISTINCT group_id) FROM tree),
  'roots_total', (SELECT count(*) FROM inventory),
  'cohorts', (SELECT jsonb_agg(to_jsonb(c) ORDER BY plan_cohort, state, discarded, expiry_age) FROM cohorts c),
  'expired_trial_and_free_review', (
    SELECT jsonb_agg(to_jsonb(i) ORDER BY expires_at, root_id)
    FROM inventory i, parameters p
    WHERE plan_cohort IN ('trial', 'free') AND discarded_at IS NULL AND expires_at < p.as_of
  )
);
ROLLBACK;
