class AddCustomFieldsToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :custom_fields, :jsonb, null: false, default: {}
  end
end
