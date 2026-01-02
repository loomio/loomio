class AddDelegateBooleanToMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :memberships, :delegate, :boolean, default: false, null: false
    add_column :groups, :delegates_count, :integer, default: 0, null: false
  end
end
