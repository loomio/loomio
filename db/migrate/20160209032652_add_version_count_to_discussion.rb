class AddVersionCountToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :versions_count, :integer, default: 0
  end
end
