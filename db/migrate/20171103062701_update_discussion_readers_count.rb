class UpdateDiscussionReadersCount < ActiveRecord::Migration
  def change
    # Discussion.find_each(batch_size: 100) { |d| d.update_seen_by_count }
  end
end
