class AddVoteWeights < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :vote_weights_enabled, :boolean, default: false, null: false
    add_column :memberships, :weight, :integer, default: 1, null: false
    add_column :stances, :weight, :integer, default: 1, null: false
  end
end
