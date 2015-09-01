class AddDefaultGroupCovers < ActiveRecord::Migration
  def change
    create_table :default_group_covers do |t|
      t.attachment :cover_photo
      t.timestamps
    end
  end
end
