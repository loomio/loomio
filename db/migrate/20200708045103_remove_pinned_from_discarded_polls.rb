class RemovePinnedFromDiscardedPolls < ActiveRecord::Migration[5.2]
  def change
    Event.where(kind: 'poll_created', eventable_id: Poll.where.not(discarded_at: nil).pluck(:id)).update_all(pinned: false)
  end
end
