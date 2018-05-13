class AddIconToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :icon, :string
  end
end
