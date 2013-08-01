class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :group
      t.integer :amount

      t.timestamps
    end
    add_index :subscriptions, :group_id
  end
end
