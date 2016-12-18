class AddDiscussionToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :closing_at, :datetime, null: true
    add_column :polls, :closed_at, :datetime, null: true
  end
end
