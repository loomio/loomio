class RevokeDiscussionReadersForRevokedMemberships < ActiveRecord::Migration[7.0]
  def change
    MigrateDiscussionReadersForDeactivatedMembersWorker.perform_async
  end
end
