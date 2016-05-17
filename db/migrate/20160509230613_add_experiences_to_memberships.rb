class AddExperiencesToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :experiences, :jsonb, null: false, default: {}
  end
end
