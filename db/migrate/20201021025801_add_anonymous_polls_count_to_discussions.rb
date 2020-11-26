class AddAnonymousPollsCountToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :anonymous_polls_count, :integer, default: 0, null: false
  end
end
