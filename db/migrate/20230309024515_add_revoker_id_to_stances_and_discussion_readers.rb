class AddRevokerIdToStancesAndDiscussionReaders < ActiveRecord::Migration[6.1]
  def change
    add_column :stances, :revoker_id, :integer
    add_column :discussion_readers, :revoker_id, :integer
  end
end
