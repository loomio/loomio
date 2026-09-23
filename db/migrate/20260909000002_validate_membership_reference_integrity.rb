class ValidateMembershipReferenceIntegrity < ActiveRecord::Migration[8.1]
  def up
    validate_foreign_key :memberships, :groups, column: :group_id
    validate_foreign_key :memberships, :users, column: :user_id
    validate_check_constraint :memberships, name: "memberships_group_id_not_null"
    validate_check_constraint :memberships, name: "memberships_user_id_not_null"

    change_column_null :memberships, :group_id, false
    change_column_null :memberships, :user_id, false

    remove_check_constraint :memberships, name: "memberships_group_id_not_null"
    remove_check_constraint :memberships, name: "memberships_user_id_not_null"
  end

  def down
    change_column_null :memberships, :user_id, true
    change_column_null :memberships, :group_id, true
  end
end
