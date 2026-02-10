class AddOpeningAtToPolls < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :opening_at, :datetime
    add_column :polls, :opened_at, :datetime
  end
end
