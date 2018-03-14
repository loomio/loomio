class AddAnnouncees < ActiveRecord::Migration[5.1]
  def change
    create_table :announcees do |t|
      t.references :announcement, index: true
      t.references :announceable, index: true, polymorphic: true
      t.jsonb :user_ids, default: [], null: false
      t.timestamps
    end
  end
end
