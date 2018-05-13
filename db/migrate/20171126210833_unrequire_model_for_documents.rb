class UnrequireModelForDocuments < ActiveRecord::Migration[4.2]
  def change
    change_column :documents, :model_id, :integer, null: true
    change_column :documents, :model_type, :string, null: true
  end
end
