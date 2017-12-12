class AddModifiedFileUrls < ActiveRecord::Migration
  def change
    add_column :documents, :web_url, :string
    add_column :documents, :thumb_url, :string
  end
end
