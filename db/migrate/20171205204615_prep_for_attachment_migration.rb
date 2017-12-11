class PrepForAttachmentMigration < ActiveRecord::Migration
  def change
    add_column :documents, :web_url, :string
    add_column :documents, :thumb_url, :string
    add_column :documents, :file_file_name, :string
  end
end
