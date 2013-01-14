class AddEventableParentIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :discussion_id, :integer
  end
end
