class AddAuthorToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :author_id, :integer, null: false, index: true
  end
end
