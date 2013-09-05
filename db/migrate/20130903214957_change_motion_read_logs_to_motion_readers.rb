class ChangeMotionReadLogsToMotionReaders < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
    has_many :votes
  end

  def up
    rename_table :motion_read_logs, :motion_readers
    rename_column :motion_readers, :motion_last_viewed_at, :last_read_at
    add_column :motion_readers, :following, :boolean, default: true, null: false
    add_column :motion_readers, :read_votes_count, :integer, default: 0, null: false
    add_column :motion_readers, :read_activity_count, :integer, default: 0, null: false
    add_index :motion_readers, [:user_id, :motion_id]
    add_index :motion_readers, [:user_id, :motion_id, :created_at]
    add_column :motions, :votes_count, :integer, default: 0, null: false
    Motion.reset_column_information

    Motion.find_each do |motion|
      motion.update_attribute(:votes_count, motion.votes.count)
    end
  end

  def down
    rename_column :motion_readers, :last_read_at, :motion_last_viewed_at
    remove_column :motion_readers, :following
    remove_column :motion_readers, :read_votes_count
    remove_column :motion_readers, :read_activity_count
    remove_index :motion_readers, [:user_id, :motion_id]
    remove_index :motion_readers, [:user_id, :motion_id, :created_at]
    remove_column :motions, :votes_count
    rename_table :motion_readers, :motion_read_logs
  end
end
