class AddAdminToStancesAndDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_column :stances,            :admin, :boolean, null: false, default: false
    add_column :discussion_readers, :admin, :boolean, null: false, default: false
  end
end
