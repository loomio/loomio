class NormalizeStanceChoiceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = "index_stance_choices_on_stance_id_and_poll_option_id"

  def up
    # Normalize before enforcing the relational invariants. The cleanup is
    # idempotent so this migration can safely be retried if an online index or
    # constraint operation is interrupted after the data transaction commits.
    stats = StanceChoiceCleanupService.cleanup!
    say "normalized stance choice integrity: #{stats.inspect}"

    add_unique_index

    add_foreign_key :stance_choices,
                    :stances,
                    column: :stance_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :stance_choices,
                    :poll_options,
                    column: :poll_option_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :poll_options,
                    :polls,
                    column: :poll_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true

    add_check_constraint :stance_choices,
                         "stance_id IS NOT NULL",
                         name: "stance_choices_stance_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :stance_choices,
                         "poll_option_id IS NOT NULL",
                         name: "stance_choices_poll_option_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :poll_options,
                         "poll_id IS NOT NULL",
                         name: "poll_options_poll_id_not_null",
                         validate: false,
                         if_not_exists: true
  end

  def down
    remove_check_constraint :poll_options,
                            name: "poll_options_poll_id_not_null",
                            if_exists: true
    remove_check_constraint :stance_choices,
                            name: "stance_choices_poll_option_id_not_null",
                            if_exists: true
    remove_check_constraint :stance_choices,
                            name: "stance_choices_stance_id_not_null",
                            if_exists: true
    remove_foreign_key :poll_options, column: :poll_id, if_exists: true
    remove_foreign_key :stance_choices, column: :poll_option_id, if_exists: true
    remove_foreign_key :stance_choices, column: :stance_id, if_exists: true
    remove_index :stance_choices, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end

  private

  def add_unique_index
    index_valid = select_value(<<~SQL.squish)
      SELECT index.indisvalid
      FROM pg_index index
      INNER JOIN pg_class index_class ON index_class.oid = index.indexrelid
      WHERE index_class.relname = #{quote(INDEX_NAME)}
    SQL

    # CREATE INDEX CONCURRENTLY can leave an invalid index behind if it is
    # interrupted. It must be removed before a retry; treating its name as an
    # existing index would leave duplicate choices unenforced.
    if index_valid == false
      remove_index :stance_choices, name: INDEX_NAME, algorithm: :concurrently
    elsif index_valid == true
      return
    end

    add_index :stance_choices,
              [ :stance_id, :poll_option_id ],
              unique: true,
              name: INDEX_NAME,
              algorithm: :concurrently
  end
end
