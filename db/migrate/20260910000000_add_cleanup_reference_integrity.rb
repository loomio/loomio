class AddCleanupReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Content and hierarchy links must reject callbackless parent deletion. Only
  # disposable dependents cascade; normal model destruction still runs callbacks.
  REFERENCES = [
    [ :groups, :groups, :parent_id, nil ],
    [ :topics, :groups, :group_id, nil ],
    [ :topic_items, :topics, :topic_id, nil ],
    [ :stances, :polls, :poll_id, nil ],
    [ :outcomes, :polls, :poll_id, nil ],
    [ :topic_readers, :topics, :topic_id, :cascade ],
    [ :topic_readers, :users, :user_id, :cascade ],
    [ :membership_requests, :groups, :group_id, :cascade ],
    [ :group_surveys, :groups, :group_id, :cascade ],
    [ :received_emails, :groups, :group_id, :cascade ],
    [ :webhooks, :groups, :group_id, :cascade ],
    [ :tags, :groups, :group_id, :cascade ],
    [ :taggings, :tags, :tag_id, :cascade ]
  ].freeze
  REQUIRED_REFERENCES = { membership_requests: :group_id, outcomes: :poll_id, tags: :group_id }.freeze

  def up
    REFERENCES.each do |table, target, column, on_delete|
      add_foreign_key table, target, column: column, on_delete: on_delete, validate: false, if_not_exists: true
    end
    REQUIRED_REFERENCES.each do |table, column|
      add_check_constraint table, "#{column} IS NOT NULL", name: "#{table}_#{column}_not_null", validate: false, if_not_exists: true
    end
  end

  def down
    REQUIRED_REFERENCES.each do |table, column|
      remove_check_constraint table, name: "#{table}_#{column}_not_null", if_exists: true
    end
    REFERENCES.reverse_each do |table, target, column, _on_delete|
      remove_foreign_key table, target, column: column
    end
  end
end
