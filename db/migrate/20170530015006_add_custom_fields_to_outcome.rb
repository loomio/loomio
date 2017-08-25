class AddCustomFieldsToOutcome < ActiveRecord::Migration
  def change
    add_column :outcomes, :custom_fields, :jsonb, default: {}, null: false
  end
end
