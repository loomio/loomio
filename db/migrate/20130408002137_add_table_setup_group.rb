class AddTableSetupGroup < ActiveRecord::Migration
  def up
    create_table :group_setups, force: true do |t|
      t.integer :group_id
      t.string :group_name
      t.text :group_description
      t.string :viewable_by, default: :members
      t.string :members_invitable_by, default: :admins
      t.string :discussion_title
      t.text :discussion_description
      t.string :motion_title
      t.text :motion_description
      t.date :close_at_date
      t.string :close_at_time_zone
      t.string :close_at_time
      t.string :admin_email
      t.text :recipients
      t.string :message_subject
      t.text :message_body

      t.timestamps
    end
  end

  def down
    drop_table :group_setups
  end
end
