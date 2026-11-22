class EnforceSingleLevelSubgroups < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Flatten any legacy multi-level subgroups directly onto their root group.
    execute <<~SQL.squish
      WITH RECURSIVE ancestors AS (
        SELECT id, parent_id, id AS root_id
        FROM groups
        WHERE parent_id IS NULL
        UNION ALL
        SELECT child.id, child.parent_id, ancestors.root_id
        FROM groups child
        JOIN ancestors ON child.parent_id = ancestors.id
      )
      UPDATE groups
      SET parent_id = ancestors.root_id
      FROM ancestors
      WHERE groups.id = ancestors.id
        AND groups.parent_id IS NOT NULL
        AND groups.parent_id <> ancestors.root_id
    SQL

    # Add both generated columns in one ALTER TABLE so groups is rewritten once.
    execute <<~SQL.squish
      ALTER TABLE groups
        ADD COLUMN is_root boolean GENERATED ALWAYS AS (parent_id IS NULL) STORED,
        ADD COLUMN parent_is_root boolean GENERATED ALWAYS AS (CASE WHEN parent_id IS NOT NULL THEN true END) STORED
    SQL

    add_index :groups, [ :id, :is_root ], unique: true, algorithm: :concurrently, name: "index_groups_on_id_and_is_root"
    add_foreign_key :groups, :groups,
      column: [ :parent_id, :parent_is_root ],
      primary_key: [ :id, :is_root ],
      name: "fk_groups_single_level_subgroup",
      validate: false
    validate_foreign_key :groups, name: "fk_groups_single_level_subgroup"
  end

  def down
    remove_foreign_key :groups, name: "fk_groups_single_level_subgroup"
    remove_index :groups, name: "index_groups_on_id_and_is_root", algorithm: :concurrently
    execute <<~SQL.squish
      ALTER TABLE groups
        DROP COLUMN parent_is_root,
        DROP COLUMN is_root
    SQL
  end
end
