class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false
      t.references :bookmarkable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :bookmarks, [:user_id, :bookmarkable_type, :bookmarkable_id], unique: true, name: 'index_bookmarks_on_user_and_bookmarkable'
  end
end
