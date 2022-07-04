class RenameProcessNameToProcessTitle < ActiveRecord::Migration[6.1]
  def change
    rename_column :polls, :process_name, :process_title
    add_column :polls, :process_subtitle, :string
    add_column :polls, :process_description_format, :string, default: 'md', null: false
  end
end
