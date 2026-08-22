class AddNotificationDeliveryFields < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_DEDUPLICATION = "index_notifications_on_user_id_and_deduplication_key"

  def up
    add_column :notifications, :kind, :string, if_not_exists: true
    add_column :notifications, :subject_type, :string, if_not_exists: true
    add_column :notifications, :subject_id, :bigint, if_not_exists: true
    add_column :notifications, :deduplication_key, :string, if_not_exists: true

    add_deduplication_index
  end

  def down
    remove_index :notifications,
                 name: INDEX_DEDUPLICATION,
                 algorithm: :concurrently,
                 if_exists: true
    remove_column :notifications, :deduplication_key, if_exists: true
    remove_column :notifications, :subject_id, if_exists: true
    remove_column :notifications, :subject_type, if_exists: true
    remove_column :notifications, :kind, if_exists: true
  end

  private

  def add_deduplication_index
    index_valid = select_value(<<~SQL.squish)
      SELECT index.indisvalid
      FROM pg_index index
      INNER JOIN pg_class index_class ON index_class.oid = index.indexrelid
      WHERE index_class.relname = #{quote(INDEX_DEDUPLICATION)}
    SQL

    # An interrupted concurrent build leaves an invalid index with the intended
    # name. Remove it before retrying so delivery identity is actually enforced.
    if index_valid == false
      remove_index :notifications, name: INDEX_DEDUPLICATION, algorithm: :concurrently
    elsif index_valid == true
      return
    end

    add_index :notifications,
              %i[user_id deduplication_key],
              unique: true,
              where: "deduplication_key IS NOT NULL",
              name: INDEX_DEDUPLICATION,
              algorithm: :concurrently
  end
end
