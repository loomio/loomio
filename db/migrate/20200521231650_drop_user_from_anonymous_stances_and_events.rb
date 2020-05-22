class DropUserFromAnonymousStancesAndEvents < ActiveRecord::Migration[5.2]
  def change
    poll_ids = Poll.where(anonymous: true).where("closed_at is not null").pluck(:id)
    stance_ids = Stance.where(poll_id: poll_ids).pluck(:id)
    puts "total polls #{Poll.count}, stances #{Stance.count}"
    puts "anonymous polls #{poll_ids.length}, anonymous stances #{stance_ids.length}"
    puts "Anonymous stances with nil participant_id: #{Stance.where(poll_id: poll_ids, participant_id: nil).count}"
    puts "Anonymous stances with participant_id: #{Stance.where(poll_id: poll_ids).where("participant_id is not null").count}"
    updated_stances_count = Stance.where(poll_id: poll_ids).update_all(participant_id: nil)
    updated_events_count = Event.where(kind: "stance_created", eventable_id: stance_ids, eventable_type: "Stance").update_all(user_id: nil)
    puts "updated stances, events", updated_stances_count, updated_events_count
  end
end
