class AddModifiedFileUrls < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :web_url, :string unless column_exists? :documents, :web_url
    add_column :documents, :thumb_url, :string unless column_exists? :documents, :thumb_url
  end
end
