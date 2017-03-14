class AddPollIdToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :poll_id, :integer, null: false, index: true
  end
end
