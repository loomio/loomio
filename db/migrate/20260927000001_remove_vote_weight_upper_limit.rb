class RemoveVoteWeightUpperLimit < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :memberships, name: "memberships_weight_in_range"
    remove_check_constraint :stances, name: "stances_weight_in_range"
    add_check_constraint :memberships, "weight >= 0", name: "memberships_weight_nonnegative"
    add_check_constraint :stances, "weight >= 0", name: "stances_weight_nonnegative"
  end

  def down
    if select_value("SELECT COUNT(*) FROM memberships WHERE weight > 1000000").to_i.positive? ||
       select_value("SELECT COUNT(*) FROM stances WHERE weight > 1000000").to_i.positive?
      raise ActiveRecord::IrreversibleMigration, "Weights above 1,000,000 must be changed before rollback"
    end

    remove_check_constraint :memberships, name: "memberships_weight_nonnegative"
    remove_check_constraint :stances, name: "stances_weight_nonnegative"
    add_check_constraint :memberships, "weight >= 0 AND weight <= 1000000", name: "memberships_weight_in_range"
    add_check_constraint :stances, "weight >= 0 AND weight <= 1000000", name: "stances_weight_in_range"
  end
end
