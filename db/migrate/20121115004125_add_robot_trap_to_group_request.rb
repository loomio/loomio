class AddRobotTrapToGroupRequest < ActiveRecord::Migration
  def change
    add_column :group_requests, :robot_trap, :string
  end
end
