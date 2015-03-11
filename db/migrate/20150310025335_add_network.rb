class AddNetwork < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.text :joining_criteria
      t.timestamps
    end
    add_index :networks, :name, unique: true
    add_index :networks, :slug, unique: true

    create_table :network_memberships do |t|
      t.integer :group_id, null: false
      t.integer :network_id, null: false
      t.timestamps
    end
    add_index :network_memberships, [:group_id, :network_id], unique: true

    create_table :network_coordinators do |t|
      t.integer :coordinator_id, null: false
      t.integer :network_id, null: false
      t.timestamps
    end
    add_index :network_coordinators, [:coordinator_id, :network_id], unique: true

    create_table :network_membership_requests do |t|
      t.integer :requestor_id, null: false
      t.integer :responder_id
      t.integer :group_id, null: false
      t.integer :network_id, null: false
      t.boolean :approved, null: true, default: nil
      t.text    :message
      t.timestamps
    end
    add_index :network_membership_requests, :network_id
    add_index :network_membership_requests, :group_id
  end
end
