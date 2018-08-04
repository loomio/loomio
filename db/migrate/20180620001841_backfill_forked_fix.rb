class BackfillForkedFix < ActiveRecord::Migration[5.1]
  def change
    forked       = Event.where(kind: :discussion_forked)
    forked_items = Event.where(id: forked.map { |e| e.custom_fields['item_ids'] }.flatten)
    forked_items.map { |e| e.eventable.update(discussion_id: e.discussion_id) }
  end
end
