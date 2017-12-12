class AddFileName < ActiveRecord::Migration
  def change
    add_column :documents, :file_file_name, :string
  end
end
