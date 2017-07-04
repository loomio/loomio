class DropNetworkCoordinators < ActiveRecord::Migration
  def change
    drop_table :network_coordinators
  end
end
