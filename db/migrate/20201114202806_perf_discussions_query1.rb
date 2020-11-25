class PerfDiscussionsQuery1 < ActiveRecord::Migration[5.2]
  def change
    add_index :discussions, [:discarded_at, :closed_at], where: '(discarded_at IS NULL and closed_at IS NULL)'
  end
end
