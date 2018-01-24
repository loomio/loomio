class PrepForAttachmentMigration < ActiveRecord::Migration
  def change
    add_column :documents, :file_file_name, :string unless column_exists? :documents, :file_file_name
  end
end
