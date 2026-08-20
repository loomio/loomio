class ValidateStanceChoiceIntegrity < ActiveRecord::Migration[8.1]
  def up
    # Validation scans existing rows without blocking normal reads and writes.
    # PostgreSQL can then reuse the validated checks when setting NOT NULL,
    # avoiding another full-table validation while holding the stronger lock.
    validate_foreign_key :stance_choices, :stances, column: :stance_id
    validate_foreign_key :stance_choices, :poll_options, column: :poll_option_id
    validate_foreign_key :poll_options, :polls, column: :poll_id

    validate_check_constraint :stance_choices, name: "stance_choices_stance_id_not_null"
    validate_check_constraint :stance_choices, name: "stance_choices_poll_option_id_not_null"
    validate_check_constraint :poll_options, name: "poll_options_poll_id_not_null"

    change_column_null :stance_choices, :stance_id, false
    change_column_null :stance_choices, :poll_option_id, false
    change_column_null :poll_options, :poll_id, false

    remove_check_constraint :stance_choices, name: "stance_choices_stance_id_not_null"
    remove_check_constraint :stance_choices, name: "stance_choices_poll_option_id_not_null"
    remove_check_constraint :poll_options, name: "poll_options_poll_id_not_null"
  end

  def down
    change_column_null :poll_options, :poll_id, true
    change_column_null :stance_choices, :poll_option_id, true
    change_column_null :stance_choices, :stance_id, true
  end
end
