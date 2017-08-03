class MigrateUndecidedCounts < ActiveRecord::Migration
  def change
    # Poll.where(example: false).find_each(batch_size: 100).map(&:update_undecided_user_count)
  end
end
