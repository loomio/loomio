require_relative 'support/online_tag_migration'

class CacheTopicTagSummaries < ActiveRecord::Migration[8.1]
  include OnlineTagMigration
  disable_ddl_transaction!

  def up
    with_short_lock_wait do
      add_column :topics, :has_tagged_replies, :boolean, default: false, null: false unless column_exists?(:topics, :has_tagged_replies)
    end
    # Existing tags remain usable immediately. Rebuild derived summaries and
    # search tags with loomio:backfill_item_tags after all processes are upgraded.
  end

  def down
    with_short_lock_wait do
      remove_column :topics, :has_tagged_replies if column_exists?(:topics, :has_tagged_replies)
    end
  end
end
