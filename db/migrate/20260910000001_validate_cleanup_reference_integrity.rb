class ValidateCleanupReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Validation is separate from installation so scans do not retain the stronger
  # ADD CONSTRAINT locks. Keep NOT VALID constraints when legacy damage exists:
  # they still protect new writes without making deployments depend on cleanup.
  def up
    references.each do |table, target, column|
      unless reference_valid?(table, target, column)
        say "Skipping validation of #{table}.#{column}: legacy orphaned rows exist"
        next
      end

      validate_foreign_key table, target, column: column
    end
    required_references.each do |table, column|
      next unless check_constraint_exists?(table, name: "#{table}_#{column}_not_null")
      if column_has_nulls?(table, column)
        say "Skipping NOT NULL promotion of #{table}.#{column}: legacy NULL rows exist"
        next
      end

      validate_check_constraint table, name: "#{table}_#{column}_not_null"
      transaction do
        change_column_null table, column, false
        remove_check_constraint table, name: "#{table}_#{column}_not_null"
      end
    end
  end

  def down
    required_references.each do |table, column|
      change_column_null table, column, true
      add_check_constraint table, "#{column} IS NOT NULL", name: "#{table}_#{column}_not_null", validate: false
    end
  end

  private

  def reference_valid?(table, target, column)
    !select_value(<<~SQL.squish)
      SELECT EXISTS (
        SELECT 1
        FROM #{quote_table_name(table)} source
        WHERE source.#{quote_column_name(column)} IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM #{quote_table_name(target)} target
            WHERE target.id = source.#{quote_column_name(column)}
          )
      )
    SQL
  end

  def column_has_nulls?(table, column)
    select_value(<<~SQL.squish)
      SELECT EXISTS (
        SELECT 1
        FROM #{quote_table_name(table)}
        WHERE #{quote_column_name(column)} IS NULL
      )
    SQL
  end

  def references
    [
      [ :groups, :groups, :parent_id ],
      [ :topics, :groups, :group_id ],
      [ :topic_items, :topics, :topic_id ],
      [ :stances, :polls, :poll_id ],
      [ :outcomes, :polls, :poll_id ],
      [ :topic_readers, :topics, :topic_id ],
      [ :topic_readers, :users, :user_id ],
      [ :membership_requests, :groups, :group_id ],
      [ :group_surveys, :groups, :group_id ],
      [ :received_emails, :groups, :group_id ],
      [ :webhooks, :groups, :group_id ],
      [ :tags, :groups, :group_id ],
      [ :taggings, :tags, :tag_id ]
    ]
  end

  def required_references
    { membership_requests: :group_id, outcomes: :poll_id, tags: :group_id }
  end
end
