class RemoveAllowLongReasonFromPolls < ActiveRecord::Migration[7.0]
  def change
    MigratePollTemplatesWorker.perform_async
    remove_column :poll_templates, :allow_long_reason, :boolean, default: false, null: false
    remove_column :polls, :allow_long_reason, :boolean, default: false, null: false
    remove_column :polls, :notify_on_participate, :boolean, default: false, null: false
    remove_column :polls, :anyone_can_participate, :boolean, default: false, null: false
    remove_column :polls, :hide_results_until_closed, :boolean, default: false, null: false
    remove_column :polls, :stances_in_discussion, :boolean, default: false, null: false
    remove_column :polls, :example, :boolean, default: false, null: false
    remove_column :polls, :guest_group_id, :integer
    remove_column :discussions, :guest_group_id, :integer
    remove_column :comments, :uses_markdown, :boolean, default: false
    remove_column :discussions, :uses_markdown, :boolean, default: false
    remove_column :users, :uses_markdown, :boolean, default: false
  end
end
