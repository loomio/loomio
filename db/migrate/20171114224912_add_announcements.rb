class AddAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :announcements do |t|
      t.references :announceable, polymorphic: true, index: true
      t.jsonb :invitation_ids, default: [], null: false
      t.jsonb :user_ids, default: [], null: false
      t.timestamps
    end
  end
end
