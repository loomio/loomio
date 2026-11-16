class CreateSpamRules < ActiveRecord::Migration[8.1]
  def up
    create_table :spam_rules do |t|
      t.string :kind, null: false
      t.text :pattern, null: false
      t.text :reason
      t.datetime :expires_at
      t.datetime :discarded_at
      t.timestamps
    end
    add_check_constraint :spam_rules, "kind IN ('ip', 'email_domain', 'regex')", name: 'spam_rules_kind'
    add_check_constraint :spam_rules, 'length(btrim(pattern)) BETWEEN 1 AND 4096', name: 'spam_rules_pattern_length'
    create_table :spam_rule_hits do |t|
      t.references :spam_rule, null: false, foreign_key: { on_delete: :cascade }
      t.string :action, null: false
      t.datetime :bucket_at, null: false
      t.bigint :count, null: false, default: 0
      t.datetime :last_matched_at, null: false
    end
    add_index :spam_rule_hits, [ :spam_rule_id, :action, :bucket_at ], unique: true
    add_index :spam_rule_hits, :bucket_at
    add_check_constraint :spam_rule_hits, 'count > 0', name: 'spam_rule_hits_positive_count'

    # Import once in the installation's environment, preserving the complete
    # existing regex. Subsequent edits have a single authority in the database.
    pattern = ENV.fetch('SPAM_REGEX', '(diide\\.com|gusronk\\.com)')
    execute <<~SQL
      INSERT INTO spam_rules (kind, pattern, reason, created_at, updated_at)
      VALUES ('regex', #{connection.quote(pattern)}, 'Imported from SPAM_REGEX', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
  end

  def down
    drop_table :spam_rule_hits
    drop_table :spam_rules
  end
end
