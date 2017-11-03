class AddDiscussionReadersCount < ActiveRecord::Migration
  def change
    add_column :discussions, :discussion_readers_count, :integer, null: false, default: 0
  end
end
