class UnrequireModelForDocuments < ActiveRecord::Migration
  def change
    change_column :documents, :model_id, :integer, null: true
    change_column :documents, :model_type, :string, null: true
  end
end
