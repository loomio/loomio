class AddDefaultGroupCovers < ActiveRecord::Migration
  def change
    create_table :default_group_covers do |t|
      t.attachment :cover_photo
      t.timestamps
    end
    add_column :groups, :default_group_cover_id, :integer
    add_index :groups, :default_group_cover_id
  end
end
