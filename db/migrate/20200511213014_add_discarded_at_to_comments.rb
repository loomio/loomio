class AddDiscardedAtToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :discarded_at, :datetime
    add_column :comments, :discarded_by, :integer
    change_column :comments, :user_id, :integer, null: true
  end
end
