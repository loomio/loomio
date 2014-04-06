class ChangeBetaFeaturesOnGroups < ActiveRecord::Migration
  def up
    remove_column :groups, :beta_features
    add_column :groups, :enabled_beta_features, :text
    add_column :discussions, :iframe_src, :string
  end

  def down
    add_column :groups, :beta_features, :boolean
    remove_column :groups, :enabled_beta_features
    remove_column :discussions, :iframe_src
  end
end
