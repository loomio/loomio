class RemoveEnableExperimentsFromGroups < ActiveRecord::Migration[7.0]
  def change
    remove_column :groups, :enable_experiments, :boolean, default: false, null: false
  end
end
