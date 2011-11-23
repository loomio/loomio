class CreateMotions < ActiveRecord::Migration
  def change
    create_table :motions do |t|
      t.string :name
      t.text :description
      t.integer :group_id
      t.integer :author_id
      t.integer :facilitator_id

      t.timestamps
    end
  end
end
