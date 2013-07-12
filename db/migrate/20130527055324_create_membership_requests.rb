class CreateMembershipRequests < ActiveRecord::Migration
  def change
    create_table :membership_requests do |t|
      t.string      :name
      t.string      :email
      t.text        :introduction
      t.references  :group
      t.references  :user

      t.timestamps
    end

    add_index :membership_requests, :name
    add_index :membership_requests, :email
    add_index :membership_requests, :group_id
    add_index :membership_requests, :user_id
  end
end
