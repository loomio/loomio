class DeleteOldMotionEvents < ActiveRecord::Migration[5.2]
  def change
    kinds = ["motion_closed", "motion_outcome_updated", "motion_outcome_created", "new_vote", "new_motion", "motion_closed_by_user", "motion_edited"]
    types = ["Motion", "Vote"]
    discussion_ids = []
    discussion_ids.concat Event.where(eventable_type: types).pluck(:discussion_id)
    discussion_ids.concat Event.where(kind: kinds).pluck(:discussion_id)
    discussion_ids.compact!
    discussion_ids.uniq!

    Event.where(eventable_type: types).delete_all
    Event.where(kind: kinds).delete_all

    discussion_ids.each do |id|
      RearrangeEventsWorker.perform_async(id)
    end
  end
end
