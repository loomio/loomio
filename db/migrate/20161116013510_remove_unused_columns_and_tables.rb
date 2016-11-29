class RemoveUnusedColumnsAndTables < ActiveRecord::Migration
  def change
    remove_column :groups, :hide_members
    remove_column :groups, :max_size
    remove_column :groups, :cannot_contribute
    remove_column :groups, :distribution_metric
    remove_column :groups, :sectors
    remove_column :groups, :other_sector
    remove_column :groups, :country_name
    remove_column :groups, :setup_completed_at
    remove_column :groups, :next_steps_completed
    remove_column :groups, :payment_plan
    remove_column :groups, :can_start_group
    remove_column :groups, :is_commercial

    remove_column :motions, :uses_markdown

    remove_column :comments, :subject

    drop_table :group_setups
    drop_table :campaigns
    drop_table :announcements
    drop_table :announcement_dismissals
  end
end
