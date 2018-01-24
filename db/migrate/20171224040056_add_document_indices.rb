class AddDocumentIndices < ActiveRecord::Migration
  def change
    add_index :documents, :model_id
    add_index :documents, :model_type
  end
end
