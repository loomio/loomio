class AddTitleToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :title, :string
  end
end
