class UpdateGroupPollsCount < ActiveRecord::Migration
  def change
    # Group.find_each(batch_size: 1000) { |u| u.update_polls_count }
  end
end
