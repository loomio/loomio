class RemoveBlankStancesFromThreads < ActiveRecord::Migration[6.1]
  def change
    query = Event.joins("LEFT OUTER JOIN stances ON stances.id = events.eventable_id and events.eventable_type = 'Stance'").where(kind: "stance_created").where("discussion_id is not null").where("stances.reason IS NULL OR stances.reason = '' OR stances.reason = '<p></p>'")
    discussion_ids = query.pluck("events.discussion_id").uniq.sort.reverse
    query.update_all(discussion_id: nil)
    discussion_ids.each { |id| RepairThreadWorker.perform_async(id) }
  end
end
