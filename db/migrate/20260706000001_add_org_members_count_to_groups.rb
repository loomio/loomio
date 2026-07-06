class AddOrgMembersCountToGroups < ActiveRecord::Migration[8.0]
  def up
    add_column :groups, :org_members_count, :integer, default: 0, null: false

    execute <<~SQL.squish
      UPDATE groups
      SET org_members_count = counts.members_count
      FROM (
        SELECT COALESCE(groups.parent_id, groups.id) AS org_id,
               COUNT(DISTINCT memberships.user_id) AS members_count
        FROM memberships
        INNER JOIN groups ON groups.id = memberships.group_id
        WHERE memberships.revoked_at IS NULL
        GROUP BY COALESCE(groups.parent_id, groups.id)
      ) counts
      WHERE groups.id = counts.org_id
        AND groups.parent_id IS NULL
    SQL
  end

  def down
    remove_column :groups, :org_members_count
  end
end
