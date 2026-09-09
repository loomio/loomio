# Migration-owned cleanup for making every membership belong to an existing
# user and group. Refresh the counters affected by callbackless deletion before
# the foreign keys and non-null checks are validated.
module MembershipReferenceIntegrityCleanup
  def self.run!(connection)
    connection.execute(<<~SQL)
      CREATE TEMPORARY TABLE membership_reference_integrity_invalid AS
      SELECT memberships.id, memberships.group_id, memberships.user_id
      FROM memberships
      WHERE memberships.group_id IS NULL
         OR memberships.user_id IS NULL
         OR NOT EXISTS (SELECT 1 FROM groups WHERE groups.id = memberships.group_id)
         OR NOT EXISTS (SELECT 1 FROM users WHERE users.id = memberships.user_id)
    SQL

    connection.execute(<<~SQL)
      DELETE FROM memberships
      WHERE memberships.id IN (SELECT id FROM membership_reference_integrity_invalid)
    SQL

    refresh_group_counters!(connection)
    refresh_user_counters!(connection)
    refresh_organisation_counters!(connection)
  ensure
    connection.execute("DROP TABLE IF EXISTS membership_reference_integrity_invalid")
  end

  def self.refresh_group_counters!(connection)
    connection.execute(<<~SQL)
      UPDATE groups
      SET memberships_count = (
            SELECT COUNT(*) FROM memberships
            WHERE memberships.group_id = groups.id AND memberships.revoked_at IS NULL
          ),
          pending_memberships_count = (
            SELECT COUNT(*) FROM memberships
            WHERE memberships.group_id = groups.id
              AND memberships.revoked_at IS NULL
              AND memberships.accepted_at IS NULL
          ),
          admin_memberships_count = (
            SELECT COUNT(*) FROM memberships
            WHERE memberships.group_id = groups.id
              AND memberships.revoked_at IS NULL
              AND memberships.admin = TRUE
          ),
          delegates_count = (
            SELECT COUNT(*) FROM memberships
            WHERE memberships.group_id = groups.id
              AND memberships.revoked_at IS NULL
              AND memberships.delegate = TRUE
          )
      WHERE groups.id IN (
        SELECT DISTINCT group_id
        FROM membership_reference_integrity_invalid
        WHERE group_id IS NOT NULL
      )
    SQL
  end
  private_class_method :refresh_group_counters!

  def self.refresh_user_counters!(connection)
    connection.execute(<<~SQL)
      UPDATE users
      SET memberships_count = (
        SELECT COUNT(*) FROM memberships
        WHERE memberships.user_id = users.id AND memberships.revoked_at IS NULL
      )
      WHERE users.id IN (
        SELECT DISTINCT user_id
        FROM membership_reference_integrity_invalid
        WHERE user_id IS NOT NULL
      )
    SQL
  end
  private_class_method :refresh_user_counters!

  def self.refresh_organisation_counters!(connection)
    connection.execute(<<~SQL)
      WITH affected_roots AS (
        SELECT DISTINCT COALESCE(groups.parent_id, groups.id) AS id
        FROM groups
        INNER JOIN membership_reference_integrity_invalid invalid
          ON invalid.group_id = groups.id
      )
      UPDATE groups roots
      SET org_members_count = (
        SELECT COUNT(DISTINCT memberships.user_id)
        FROM memberships
        INNER JOIN groups member_groups ON member_groups.id = memberships.group_id
        WHERE memberships.revoked_at IS NULL
          AND (member_groups.id = roots.id OR member_groups.parent_id = roots.id)
      )
      WHERE roots.id IN (SELECT id FROM affected_roots)
    SQL
  end
  private_class_method :refresh_organisation_counters!
end
