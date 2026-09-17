class CreateGroupFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :group_follows do |t|
      t.references :group, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    add_index :group_follows, [ :user_id, :group_id ], unique: true
  end
end
