class ReplaceEmailFailureCounters < ActiveRecord::Migration[7.2]
  def up
    create_table :email_suppressions do |t|
      t.string :email_sha256, null: false
      t.string :reason, null: false
      t.string :source_key, null: false
      t.references :notification_delivery_event, foreign_key: { on_delete: :nullify }
      t.datetime :occurred_at
      t.datetime :cleared_at
      t.references :cleared_by, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :clear_method
      t.timestamps
    end
    add_index :email_suppressions, :source_key, unique: true
    add_index :email_suppressions, :email_sha256, where: 'cleared_at IS NULL', name: 'index_email_suppressions_active_address'
    add_index :email_suppressions, [ :email_sha256, :id ]
    add_column :notification_delivery_events, :bounce_type, :string

    # Counters contain neither the original address nor a reliable event date.
    # Preserve their current blocking effect without inventing delivery evidence.
    %w[bounce complaint].each do |kind|
      column = kind == 'bounce' ? 'bounces_count' : 'complaints_count'
      execute <<~SQL
        INSERT INTO email_suppressions (email_sha256, reason, source_key, created_at, updated_at)
        SELECT encode(digest(lower(btrim(email)), 'sha256'), 'hex'), 'legacy_#{kind}',
               'legacy:#{kind}:' || id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM users WHERE #{column} > 0 AND email IS NOT NULL AND btrim(email) <> ''
      SQL
    end
    remove_column :users, :bounces_count
    remove_column :users, :complaints_count
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Suppression evidence and clearance history cannot be restored to counters'
  end
end
