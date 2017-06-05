class AddVisitorCountToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :visitors_count, :integer, null: false, default: 0
  end
end
