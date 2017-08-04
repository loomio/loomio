class ResetLastItemAt < ActiveRecord::Migration
  def change
    puts "Resetting last_item_at, last_sequence_id for all discussions"
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          order('discussion_id, events.created_at desc').each do |item|
      raise item.inspect if item.sequence_id.nil?
      Discussion.where(id: item.discussion_id).update_all(last_item_at: item.created_at,
                                                          last_sequence_id: item.sequence_id || 0)
    end
  end
end
