class AddTableSetupGroup < ActiveRecord::Migration
  def up
    create_table :group_setups do |t|
      t.integer :group_id
      t.string :group_name
      t.text :group_description
      t.string :viewable_by, default: :members
      t.string :members_invitable_by, default: :admins
      t.integer :discussion_id
      t.string :discussion_title
      t.text :discussion_description
      t.integer :motion_id
      t.string :motion_title
      t.text :motion_description
      t.datetime :close_date
      t.string :admin_email
      t.text :members_list
      t.string :invite_subject
      t.text :invite_body

      t.timestamps
    end
  end

  def down
    drop_table :group_setups
  end
end