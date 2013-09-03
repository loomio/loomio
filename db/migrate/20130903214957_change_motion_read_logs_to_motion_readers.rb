class ChangeMotionReadLogsToMotionReaders < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
    has_many :votes
  end

  def up
    rename_table :motion_read_logs, :motion_readers
    rename_column :motion_last_viewed_at, :last_read_at
    add_column :following, :boolean, default: true, null: false
    add_column :read_votes_count, :integer
    add_index :motion_readers, [:user_id, :motion_id]
    add_column :motions, :votes_count, :integer, default: 0, null: false
    Motion.reset_column_information

    Motion.find_each do |motion|
      motion.update_attribute(:votes_count, motion.votes.count)
    end
  end

  def down
    rename_table :motion_readers, :motion_read_logs
    rename_column :last_read_at, :motion_last_viewed_at
    remove_column :following
    remove_column :read_votes_count
    remove_index :motion_readers, [:user_id, :motion_id]
    remove_column :votes_count
  end
end
