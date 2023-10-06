class RemoveExperiencesFromGroups < ActiveRecord::Migration[7.0]
  def change
    remove_column :groups, :experiences, :jsonb, default: {}, null: false
  end
end
