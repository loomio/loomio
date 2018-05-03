class AddAnnouncementCountToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :announcement_recipients_count, :integer, default: 0, null: false
  end
end
