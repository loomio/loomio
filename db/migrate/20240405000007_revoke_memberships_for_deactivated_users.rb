class RevokeMembershipsForDeactivatedUsers < ActiveRecord::Migration[7.0]
  def change
    RevokeMembershipsOfDeactivatedUsersWorker.perform_async
  end
end
