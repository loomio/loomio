class AddTopicItemParentTopicIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = "index_topic_items_on_id_and_topic_id"
  FOREIGN_KEY_NAME = "topic_items_parent_same_topic"

  def up
    add_index :topic_items,
              [ :id, :topic_id ],
              unique: true,
              name: INDEX_NAME,
              algorithm: :concurrently,
              if_not_exists: true

    transaction { normalize_parent_topics! }

    add_foreign_key :topic_items,
                    :topic_items,
                    column: [ :parent_id, :topic_id ],
                    primary_key: [ :id, :topic_id ],
                    name: FOREIGN_KEY_NAME,
                    on_delete: :cascade,
                    validate: false
  end

  def down
    remove_foreign_key :topic_items, name: FOREIGN_KEY_NAME, if_exists: true
    remove_index :topic_items, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end

  private

  # TopicItem ancestry is a projection of the itemable relationships. Repair
  # mismatches from that source of truth, then rebuild both the old and new
  # topic trees. Repeating catches descendants exposed when an ancestor moves.
  def normalize_parent_topics!
    TopicItem.reset_column_information
    count_previous = nil

    loop do
      mismatches = parent_topic_mismatches
      count = mismatches.count
      break if count.zero?
      raise "topic item parent/topic repair made no progress with #{count} rows" if count == count_previous

      topic_ids = []
      mismatches.find_each do |topic_item|
        parent = TopicItem.find(topic_item.parent_id)
        canonical_topic = topic_item.itemable&.topic
        unless canonical_topic&.persisted?
          raise "TopicItem #{topic_item.id} has no canonical itemable topic"
        end

        topic_ids.concat([ topic_item.topic_id, parent.topic_id, canonical_topic.id ])
        # sequence_id is derived within a topic. Clear it while crossing the
        # topic boundary so the target topic's unique sequence index cannot
        # collide before TopicService repairs both trees below. Keeping the old
        # parent temporarily makes an interrupted pass discoverable on retry.
        topic_item.update_columns(topic_id: canonical_topic.id, sequence_id: nil)
      end

      topic_ids.compact.uniq.each do |topic_id|
        TopicService.repair(topic_id)
      end
      count_previous = count
    end
  end

  def parent_topic_mismatches
    TopicItem
      .joins("INNER JOIN topic_items parents ON parents.id = topic_items.parent_id")
      .where("topic_items.topic_id IS DISTINCT FROM parents.topic_id")
  end
end
