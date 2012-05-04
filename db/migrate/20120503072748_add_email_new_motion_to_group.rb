class AddEmailNewMotionToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :email_new_motion, :boolean, default: true
  end
end
