class CreateAnnouncementDismissals < ActiveRecord::Migration
  def change
    unless table_exists? :announcement_dismissals
      create_table :announcement_dismissals do |t|
        t.references :announcement
        t.references :user

        t.timestamps
      end
      add_index :announcement_dismissals, :announcement_id
      add_index :announcement_dismissals, :user_id
    end
  end
end
