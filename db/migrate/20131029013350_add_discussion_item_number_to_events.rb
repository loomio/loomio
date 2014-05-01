class AddDiscussionItemNumberToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sequence_id, :integer, default: nil, null: true
    add_index :events, [:discussion_id, :sequence_id], unique: true
  end
end
