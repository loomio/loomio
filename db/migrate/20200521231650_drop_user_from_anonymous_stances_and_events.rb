class DropUserFromAnonymousStancesAndEvents < ActiveRecord::Migration[5.2]
  def change
    closed_anonymous_poll_ids = Poll.where(anonymous: true).where("closed_at is not null").pluck(:id)
    Stance.where(poll_id: closed_anonymous_poll_ids).update_all(participant_id: nil)

    anonymous_stance_ids = Stance.joins(:poll).where('polls.anonymous': true).pluck(:id)
    Event.where(kind: "stance_created", eventable_id: anonymous_stance_ids, eventable_type: "Stance").update_all(user_id: nil)
  end
end
