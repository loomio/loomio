class AddRevokedAtToSessions < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_column :sessions, :revoked_at, :datetime
    add_index :sessions, :revoked_at, where: "revoked_at IS NOT NULL", algorithm: :concurrently
  end

  def down
    # Older authentication code accepts every session row. Remove retained
    # revoked credentials before removing the field that keeps them inactive.
    loop do
      removed = connection.delete(<<~SQL)
        DELETE FROM sessions WHERE id IN (
          SELECT id FROM sessions WHERE revoked_at IS NOT NULL ORDER BY id LIMIT 1000
        )
      SQL
      break if removed.zero?
    end

    remove_index :sessions, :revoked_at, algorithm: :concurrently
    remove_column :sessions, :revoked_at
  end
end
