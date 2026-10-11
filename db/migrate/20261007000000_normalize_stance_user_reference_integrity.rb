require_relative "support/stance_user_reference_integrity_cleanup"

class NormalizeStanceUserReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  USER_REFERENCES = {
    participant_id: :cascade,
    inviter_id: :nullify,
    revoker_id: :nullify,
    redactor_id: :nullify
  }.freeze

  def up
    USER_REFERENCES.each do |column, on_delete|
      add_foreign_key :stances,
                      :users,
                      column: column,
                      on_delete: on_delete,
                      validate: false,
                      if_not_exists: true
    end

    add_check_constraint :stances,
                         "participant_id IS NOT NULL",
                         name: "stances_participant_id_not_null",
                         validate: false,
                         if_not_exists: true

    StanceUserReferenceIntegrityCleanup.run!(connection)
  end

  def down
    remove_check_constraint :stances, name: "stances_participant_id_not_null", if_exists: true
    USER_REFERENCES.keys.reverse_each do |column|
      remove_foreign_key :stances, column: column, if_exists: true
    end
  end
end
