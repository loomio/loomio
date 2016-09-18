class AddWatching < ActiveRecord::Migration
  def change
    add_column :groups, :watching_enabled, :boolean, default: false, null: false
    add_column :discussion_readers, :watching, :boolean, default: false, null: false
    add_column :discussion_readers, :watching_reason, :string
    add_column :users, :email_watched_threads, :boolean, default: false, null: false
  end
end
