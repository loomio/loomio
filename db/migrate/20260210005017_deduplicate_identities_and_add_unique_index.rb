class DeduplicateIdentitiesAndAddUniqueIndex < ActiveRecord::Migration[7.0]
  def up
    # Legacy code created a new orphan identity record (user_id NULL) on every
    # OAuth login instead of reusing the existing one. This left hundreds of
    # thousands of duplicate rows per (identity_type, uid).
    #
    # Step 1: Delete orphans where a linked identity already exists for the same uid
    execute <<~SQL
      DELETE FROM omniauth_identities
      WHERE user_id IS NULL
      AND (identity_type, uid) IN (
        SELECT identity_type, uid
        FROM omniauth_identities
        WHERE user_id IS NOT NULL
        GROUP BY identity_type, uid
      )
    SQL

    # Step 2: For uids that have ONLY orphan records (no linked user), keep the
    # most recent one and delete the rest
    execute <<~SQL
      DELETE FROM omniauth_identities
      WHERE user_id IS NULL
      AND id NOT IN (
        SELECT DISTINCT ON (identity_type, uid) id
        FROM omniauth_identities
        WHERE user_id IS NULL
        ORDER BY identity_type, uid, created_at DESC
      )
    SQL

    # Step 3: For the 16 cases where the same uid is linked to multiple
    # different users, keep the most recently created identity (the one
    # they're actively using) and delete the older ones.
    execute <<~SQL
      DELETE FROM omniauth_identities
      WHERE id NOT IN (
        SELECT DISTINCT ON (identity_type, uid) id
        FROM omniauth_identities
        ORDER BY identity_type, uid, id DESC
      )
    SQL

    # Step 4: Prevent future duplicates
    remove_index :omniauth_identities, [:identity_type, :uid], if_exists: true
    add_index :omniauth_identities, [:identity_type, :uid], unique: true
  end

  def down
    remove_index :omniauth_identities, [:identity_type, :uid]
  end
end
