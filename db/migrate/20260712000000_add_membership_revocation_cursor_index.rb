class AddMembershipRevocationCursorIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :memberships,
              [:revoked_at, :id],
              where: "revoked_at IS NOT NULL",
              name: :index_memberships_on_revoked_at_and_id_for_relay,
              algorithm: :concurrently,
              if_not_exists: true
  end
end
