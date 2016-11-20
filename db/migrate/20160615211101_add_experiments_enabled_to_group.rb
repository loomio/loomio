class AddExperimentsEnabledToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :enable_experiments, :boolean, default: false
  end
end
