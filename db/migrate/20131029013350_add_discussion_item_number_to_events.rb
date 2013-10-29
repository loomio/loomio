class AddDiscussionItemNumberToEvents < ActiveRecord::Migration
  def change
    add_column :events, :discussion_item_number, :integer, default: nil, null: true
    add_index :events, [:discussion_id, :discussion_item_number], unique: true
  end
end
