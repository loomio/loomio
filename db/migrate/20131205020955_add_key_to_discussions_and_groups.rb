class AddKeyToDiscussionsAndGroups < ActiveRecord::Migration
  def up
    add_column :discussions, :key, :string
    add_column :groups,      :key, :string

    add_index :discussions,  :key, unique: true
    add_index :groups,       :key, unique: true
  end

  def down
   remove_column :discussions, :key
   remove_column :groups,      :key
  end
end
