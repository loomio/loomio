class RemoveDiscussionTotalViews < ActiveRecord::Migration
  def up
    remove_column :discussions, :total_views
  end
end
