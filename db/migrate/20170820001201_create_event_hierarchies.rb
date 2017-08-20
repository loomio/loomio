class CreateEventHierarchies < ActiveRecord::Migration
  def change
    create_table :event_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :event_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "event_anc_desc_idx"

    add_index :event_hierarchies, [:descendant_id],
      name: "event_desc_idx"
  end
end
