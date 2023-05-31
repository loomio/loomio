class AddTagsArrayToPollsAndDiscussions < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :tags, :string, array: true, default: []
    add_column :discussions, :tags, :string, array: true, default: []
    add_index :polls, :tags, using: 'gin'
    add_index :discussions, :tags, using: 'gin'
  end
end
