class FixPollReminderEvents < ActiveRecord::Migration[6.0]
  def change
    discussion_ids = Event.where(kind: 'poll_reminder').pluck(:discussion_id).compact.uniq
    Event.where(kind: 'poll_reminder').update_all(discussion_id: nil, sequence_id: nil, position: 0)
    discussion_ids.each {|id| EventService.delay.repair_thread(id) }
  end
end
