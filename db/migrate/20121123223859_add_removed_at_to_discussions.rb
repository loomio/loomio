class AddRemovedAtToDiscussions < ActiveRecord::Migration
  def change
  	add_column :discussions, :removed_at, :timestamp, :default => nil
  end
end
