class AddBetaFeaturesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :beta_features, :text
  end
end
