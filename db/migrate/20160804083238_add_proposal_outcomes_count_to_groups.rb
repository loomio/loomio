class AddProposalOutcomesCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :proposal_outcomes_count, :integer, default: 0, null: false
  end
end
