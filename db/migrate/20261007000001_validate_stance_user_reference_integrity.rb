class ValidateStanceUserReferenceIntegrity < ActiveRecord::Migration[8.1]
  def up
    validate_foreign_key :stances, :users, column: :participant_id
    validate_foreign_key :stances, :users, column: :inviter_id
    validate_foreign_key :stances, :users, column: :revoker_id
    validate_foreign_key :stances, :users, column: :redactor_id
    validate_check_constraint :stances, name: "stances_participant_id_not_null"

    change_column_null :stances, :participant_id, false

    remove_check_constraint :stances, name: "stances_participant_id_not_null"
  end

  def down
    change_column_null :stances, :participant_id, true
  end
end
