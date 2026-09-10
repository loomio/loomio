class ValidateCleanupReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Validation is separate from installation so scans do not retain the stronger
  # ADD CONSTRAINT locks. Fail on legacy damage; never delete or reparent content.
  def up
    references.each do |table, target, column|
      validate_foreign_key table, target, column: column
    end
    required_references.each do |table, column|
      next unless check_constraint_exists?(table, name: "#{table}_#{column}_not_null")

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
