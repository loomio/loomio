class AddTokenToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_column :discussion_readers, :token, :string
    add_index :discussion_readers, :token, unique: true
  end
end
