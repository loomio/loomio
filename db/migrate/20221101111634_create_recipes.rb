class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.string :url
      t.string :title
      t.string :body
      t.timestamps
    end
  end
end
