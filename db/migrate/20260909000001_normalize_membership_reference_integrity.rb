require_relative "support/membership_reference_integrity_cleanup"

class NormalizeMembershipReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_foreign_key :memberships,
                    :groups,
                    column: :group_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :memberships,
                    :users,
                    column: :user_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true

    add_check_constraint :memberships,
                         "group_id IS NOT NULL",
                         name: "memberships_group_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :memberships,
                         "user_id IS NOT NULL",
                         name: "memberships_user_id_not_null",
                         validate: false,
                         if_not_exists: true

    MembershipReferenceIntegrityCleanup.run!(connection)
  end

  def down
    remove_check_constraint :memberships, name: "memberships_user_id_not_null", if_exists: true
    remove_check_constraint :memberships, name: "memberships_group_id_not_null", if_exists: true
    remove_foreign_key :memberships, column: :user_id, if_exists: true
    remove_foreign_key :memberships, column: :group_id, if_exists: true
  end
end
