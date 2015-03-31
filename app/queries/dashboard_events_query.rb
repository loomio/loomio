class DashboardEventsQuery
  def self.latest_events_for(user)
    visible_discussion_ids_for(user)
    events = Event.where(discussion_id: visible_discussion_ids_for(user))
                  .order(sequence_id: :desc)
                  .group_by(&:discussion_id)
                  .map { |d, events| events.first }
  end

  private

  def self.visible_discussion_ids_for(user)
    Queries::VisibleDiscussions.new(user: user).not_muted.pluck(:id)
  end
end
