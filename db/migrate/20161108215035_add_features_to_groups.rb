class AddFeaturesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :features, :jsonb, null: false, default: {}
    Group.where("enabled_beta_features like ?", "%export%").update_all(features: {dataExport: true}.to_json)
    remove_column :groups, :enabled_beta_features, :string
  end
end
