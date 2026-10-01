# Adds vote weights in their final shape so upgrading avoids rewriting large
# tables. New columns with constant defaults are metadata-only changes, so
# stances and memberships are not rewritten. Only poll_options is rewritten, to
# hold fractional weighted totals.
#
# The weight checks are added NOT VALID so this migration does not scan
# stances while holding its exclusive lock; the next migration validates them
# under a lock that allows reads and writes.
class AddVoteWeights < ActiveRecord::Migration[8.1]
  def up
    add_column :polls, :weighted_voting, :boolean, default: false, null: false
    add_column :poll_templates, :weighted_voting, :boolean, default: false, null: false

    add_column :memberships, :weight, :decimal, precision: 12, scale: 3, default: 1, null: false
    add_column :stances, :weight, :decimal, precision: 12, scale: 3, default: 1, null: false
    add_check_constraint :memberships, 'weight >= 0', name: 'memberships_weight_nonnegative', validate: false
    add_check_constraint :stances, 'weight >= 0', name: 'stances_weight_nonnegative', validate: false

    change_column :poll_options, :total_score, :decimal, precision: 30, scale: 3, default: 0, null: false
    add_column :poll_options, :unweighted_score, :bigint, default: 0, null: false
    add_column :poll_options, :voter_weight_total, :decimal, precision: 30, scale: 3, default: 0, null: false
  end

  def down
    remove_column :poll_options, :voter_weight_total
    remove_column :poll_options, :unweighted_score
    change_column :poll_options, :total_score, :integer, default: 0, null: false

    remove_check_constraint :stances, name: 'stances_weight_nonnegative'
    remove_check_constraint :memberships, name: 'memberships_weight_nonnegative'
    remove_column :stances, :weight
    remove_column :memberships, :weight

    remove_column :poll_templates, :weighted_voting
    remove_column :polls, :weighted_voting
  end
end
