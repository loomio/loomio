class AddGroupIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :group_id, :integer
    add_index :documents, :group_id
    AddGroupIdToDocumentsJob.perform_later
  end
end
