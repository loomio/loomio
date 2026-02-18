class AddNotifyOnOpenToPolls < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :notify_on_open, :boolean, default: true, null: false
    add_column :poll_templates, :notify_on_open, :boolean, default: true, null: false
  end
end
