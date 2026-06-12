class CreateGroupHandleRedirects < ActiveRecord::Migration[8.0]
  def change
    create_table :group_handle_redirects do |t|
      t.references :group, null: false, foreign_key: true
      t.citext :handle, null: false
      t.timestamps
    end

    add_index :group_handle_redirects, :handle, unique: true
    add_index :group_handle_redirects, [:group_id, :handle], unique: true
  end
end
