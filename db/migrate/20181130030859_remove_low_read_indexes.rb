class RemoveLowReadIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :versions,           name: :index_versions_on_whodunnit
    remove_index :notifications,      name: :index_notifications_on_created_at
    remove_index :notifications,      name: :index_notifications_on_viewed
    remove_index :notifications,      name: :index_notifications_on_actor_id
    remove_index :ahoy_messages,      name: :index_ahoy_messages_on_sent_at
    remove_index :ahoy_messages,      name: :index_ahoy_messages_on_to
    remove_index :ahoy_messages,      name: :index_ahoy_messages_on_user_id_and_user_type
    remove_index :discussion_readers, name: :index_discussion_readers_on_user_id_and_volume
    remove_index :discussion_readers, name: :index_motion_read_logs_on_user_id
    remove_index :visits,             name: :index_visits_on_user_id
    remove_index :ahoy_events,        name: :index_ahoy_events_on_user_id
    remove_index :ahoy_events,        name: :index_ahoy_events_on_visit_id
    remove_index :events,             name: :index_events_on_parent_id_and_position
    remove_index :events,             name: :index_events_on_parent_id
    remove_index :events,             name: :index_events_on_kind
  end
end
