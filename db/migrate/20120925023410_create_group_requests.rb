class CreateGroupRequests < ActiveRecord::Migration
  def change
    create_table :group_requests do |t|
      t.string :name
      t.integer :expected_size
      t.text :description
      t.string :admin_email
      t.text :member_emails

      t.timestamps
    end
  end
end
