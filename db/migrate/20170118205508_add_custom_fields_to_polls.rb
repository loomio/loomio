class AddCustomFieldsToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :custom_fields, :jsonb, null: false, default: {}
  end
end
