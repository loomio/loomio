class PrepForAttachmentMigration < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :file_file_name, :string unless column_exists? :documents, :file_file_name
  end
end
