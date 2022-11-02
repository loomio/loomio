class AddRecipeIdToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :recipe_url, :string
  end
end
