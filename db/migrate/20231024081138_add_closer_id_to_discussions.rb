class AddCloserIdToDiscussions < ActiveRecord::Migration[7.0]
  def change
    add_column :discussions, :closer_id, :integer
  end
end
