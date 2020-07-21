class IncludeSubgroupsToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :include_subgroups, :boolean, default: false, null: false
  end
end
