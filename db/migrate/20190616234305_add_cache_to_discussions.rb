class AddCacheToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :cache, :jsonb, default: {}, null: false
  end
end
