class RenameTopicClosedAtToLockedAt < ActiveRecord::Migration[8.0]
  def change
    rename_column :topics, :closed_at, :locked_at if column_exists?(:topics, :closed_at)
    rename_column :topics, :closer_id, :locker_id if column_exists?(:topics, :closer_id)
  end
end
