class AddExperiencesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :experiences, :jsonb, null: false, default: {}
  end
end
