class ResequenceBrokenSequences < ActiveRecord::Migration

  def change
    Event.where(kind: 'new_discussion').update_all(discussion_id: nil)

    remove_index :events, name: :index_events_on_discussion_id_and_sequence_id

    discussion_ids = Event.where('discussion_id is not null').where('sequence_id is null').pluck(:discussion_id).uniq

    discussion_ids.each do |discussion_id|
      i = 0
      Event.where(discussion_id: discussion_id).order('created_at asc').each do |event|
        i += 1
        Event.where(id: event.id).update_all(sequence_id: i)
      end
    end

    add_index "events", ["discussion_id", "sequence_id"], name: "index_events_on_discussion_id_and_sequence_id", unique: true, using: :btree
  end
end
