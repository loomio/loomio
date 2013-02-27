class AddTotalViewsToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :total_views, :integer, default: 0, null: false
  end
end
