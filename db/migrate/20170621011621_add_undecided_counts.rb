class AddUndecidedCounts < ActiveRecord::Migration
  def change
    add_column :polls, :undecided_user_count, :integer, default: 0, null: false
    add_column :polls, :undecided_visitor_count, :integer, default: 0, null: false
    remove_column :polls, :did_not_votes_count, :integer, default: 0, null: false
  end
end
