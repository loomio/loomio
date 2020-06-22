class AddDiscardedAtToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :discarded_at, :datetime
    add_column :polls, :discarded_by, :integer
  end
end
