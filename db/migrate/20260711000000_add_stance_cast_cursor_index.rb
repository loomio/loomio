class AddStanceCastCursorIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :stances,
              [:cast_at, :id],
              where: "cast_at IS NOT NULL AND redacted_at IS NULL",
              name: :index_stances_on_cast_at_and_id_for_relay,
              algorithm: :concurrently,
              if_not_exists: true
  end
end
