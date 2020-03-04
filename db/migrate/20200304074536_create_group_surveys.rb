class CreateGroupSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :group_surveys
    add_column :group_surveys, :group_id, :integer, null: false
    add_column :group_surveys, :category, :string
    add_column :group_surveys, :location, :string
    add_column :group_surveys, :size, :string
    add_column :group_surveys, :declaration, :string
    add_column :group_surveys, :purpose, :text
    add_column :group_surveys, :usage, :string
    add_column :group_surveys, :referrer, :string
    add_column :group_surveys, :role, :string
    add_column :group_surveys, :website, :string
    add_column :group_surveys, :misc, :text
    add_timestamps :group_surveys
    add_index  :group_surveys, :group_id
  end
end
