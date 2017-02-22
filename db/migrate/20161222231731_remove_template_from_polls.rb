class RemoveTemplateFromPolls < ActiveRecord::Migration
  def change
    remove_column :polls, :poll_template_id
    remove_column :polls, :can_add_options
    remove_column :polls, :can_remove_options
    remove_column :polls, :graph_type
    remove_column :polls, :allow_custom_options
    remove_column :poll_options, :poll_template_id
    remove_column :poll_options, :icon_url
  end
end
