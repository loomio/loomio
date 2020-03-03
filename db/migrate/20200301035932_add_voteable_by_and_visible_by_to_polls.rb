class AddVoteableByAndVisibleByToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :voteable_by, :string, default: :group
    add_column :polls, :visible_by, :string, default: :group
  end
end
