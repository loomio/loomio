class AddEmailAnnouncements < ActiveRecord::Migration
  def change
    add_column :users, :email_announcements, :boolean, default: true, null: false
  end
end
