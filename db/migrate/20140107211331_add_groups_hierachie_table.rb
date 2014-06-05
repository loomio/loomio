class AddGroupsHierachieTable < ActiveRecord::Migration
  def change
    create_table :group_hierarchies, id: false, force: true do |t|
      t.integer  :ancestor_id, null: false   # ID of the parent/grandparent/great-grandparent/... tag
      t.integer  :descendant_id, null: false # ID of the target tag
      t.integer  :generations, null: false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end

    # For "all progeny of…" and leaf selects:
    add_index :group_hierarchies, [:ancestor_id, :descendant_id, :generations], :unique => true, :name => "group_anc_desc_udx"

    # For "all ancestors of…" selects,
    add_index :group_hierarchies, [:descendant_id], :name => "group_desc_idx"
  end
end
