class CreateGroupVisits < ActiveRecord::Migration
  def change
    create_table :group_visits do |t|
      t.uuid :visit_id
      t.integer :group_id
      t.timestamps
    end
    add_index :group_visits, [:visit_id, :group_id] , unique: true

    create_table :organisation_visits do |t|
      t.uuid :visit_id
      t.integer :organisation_id
      t.timestamps
    end
    add_index :organisation_visits, [:visit_id, :organisation_id] , unique: true
  end
end
