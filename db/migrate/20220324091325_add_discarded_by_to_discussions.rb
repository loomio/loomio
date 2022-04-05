class AddDiscardedByToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :discarded_by, :integer
  end
end
