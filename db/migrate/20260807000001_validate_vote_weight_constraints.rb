# Validating separately takes a SHARE UPDATE EXCLUSIVE lock, so reads and
# writes continue while stances and memberships are scanned.
class ValidateVoteWeightConstraints < ActiveRecord::Migration[8.1]
  def change
    validate_check_constraint :memberships, name: 'memberships_weight_nonnegative'
    validate_check_constraint :stances, name: 'stances_weight_nonnegative'
  end
end
