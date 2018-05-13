class UpdateDiscussionReadersCount < ActiveRecord::Migration[4.2]
  def change
    # this kills automatic migration on large isntalls, and isnt totally necessary
    # Discussion.find_each(batch_size: 100) { |d| d.update_seen_by_count }
  end
end
