class AddDocumentIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :documents, :model_id
    add_index :documents, :model_type
  end
end
