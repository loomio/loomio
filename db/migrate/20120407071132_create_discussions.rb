class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.references :group
      t.integer :author_id

      t.timestamps
    end
    add_index :discussions, :group_id
    add_index :discussions, :author_id
  end
end
