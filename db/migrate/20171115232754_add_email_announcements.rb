class AddEmailAnnouncements < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_announcements, :boolean, default: true, null: false
  end
end
