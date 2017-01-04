class AddPriorityToPollOptions < ActiveRecord::Migration
  def change
    add_column :poll_options, :priority, :integer, default: 0, null: false
    add_index :poll_options, :priority
  end

end
