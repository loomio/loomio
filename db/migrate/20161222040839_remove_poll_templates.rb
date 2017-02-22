class RemovePollTemplates < ActiveRecord::Migration
  def change
    drop_table :poll_templates, {}
    drop_table :poll_poll_options, {}
    add_column :poll_options, :poll_id, :integer
    add_column :polls, :can_add_options, :boolean, default: false, null: false
    add_column :polls, :can_remove_options, :boolean, default: false, null: false
    add_column :polls, :poll_type, :string, null: false
    add_column :polls, :graph_type, :string, null: false
    add_column :polls, :motion_id, :integer, null: true
    rename_column :polls, :name, :title
    rename_column :polls, :description, :details
  end
end
