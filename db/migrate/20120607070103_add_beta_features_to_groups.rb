class AddBetaFeaturesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :beta_features, :boolean, :default => false
  end
end
