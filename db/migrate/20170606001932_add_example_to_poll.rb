class AddExampleToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :example, :boolean, default: false, null: false
  end
end
