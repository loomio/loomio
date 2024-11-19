class AddContentIsPublicToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :content_is_public, :boolean, default: false, null: false
  end
end
