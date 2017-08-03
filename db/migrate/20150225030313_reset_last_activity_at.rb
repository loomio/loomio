class ResetLastActivityAt < ActiveRecord::Migration
  def change
    puts "Resetting last_activity_at for all discussions"
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          where(kind: Discussion::SALIENT_ITEM_KINDS).
          order('discussion_id, events.created_at desc').each do |item|
      Discussion.where(id: item.discussion_id).update_all(last_activity_at: item.created_at)
    end
    Discussion.where(last_activity_at: nil).update_all('last_activity_at = created_at')
  end
end
