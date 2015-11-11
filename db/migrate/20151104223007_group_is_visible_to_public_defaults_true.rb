class GroupIsVisibleToPublicDefaultsTrue < ActiveRecord::Migration
  def change
    change_column :groups, :is_visible_to_public, :boolean, default: true, null: false
  end
end
