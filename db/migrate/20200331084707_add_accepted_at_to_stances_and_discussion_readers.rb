class AddAcceptedAtToStancesAndDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_column :discussion_readers, :accepted_at, :datetime
    add_column :stances, :accepted_at, :datetime
  end
end
