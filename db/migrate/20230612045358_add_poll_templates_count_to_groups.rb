class AddPollTemplatesCountToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :poll_templates_count, :integer, default: 0, null: false
  end
end
