class AddCustomFieldsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :custom_fields, :jsonb, default: {}, null: false
  end
end
