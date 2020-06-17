class UnpinnDiscardedComments < ActiveRecord::Migration[5.2]
  def change
    comment_ids = Comment.where("discarded_at is not null").pluck(:id)
    Event.where(kind: "new_comment").where(eventable_id: comment_ids).update_all(pinned: false)
  end
end
