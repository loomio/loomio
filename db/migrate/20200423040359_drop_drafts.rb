class DropDrafts < ActiveRecord::Migration[5.2]
  def change
    drop_table :drafts
  end
end
