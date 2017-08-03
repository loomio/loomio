class ResetFirstSequenceId < ActiveRecord::Migration
  def change
    #first_sequence_id
    puts "Resetting first_sequence_id for all discussions"
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          order('discussion_id, events.created_at asc').each do |item|
      Discussion.where(id: item.discussion_id).update_all(first_sequence_id: item.sequence_id)
    end
  end
end
