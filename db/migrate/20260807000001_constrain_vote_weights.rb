class ConstrainVoteWeights < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :memberships,
                         'weight >= 0 AND weight <= 1000000',
                         name: 'memberships_weight_in_range'
    add_check_constraint :stances,
                         'weight >= 0 AND weight <= 1000000',
                         name: 'stances_weight_in_range'
  end
end
