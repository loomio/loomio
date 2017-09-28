class AddAuthorToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :author_id, :integer, null: false, index: true
  end
end
