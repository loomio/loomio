class AddPriorityToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :priority, :integer, default: 0, null: false
  end
end
