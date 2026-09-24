class AddVoteWeightsAllowedToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :vote_weights_allowed, :boolean, default: false, null: false
  end
end
