class AddMembersCountToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :members_count, :integer
  end
end
