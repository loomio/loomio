class LatestEventsQuery
  def self.latest_events_for(user, discussion_ids: [])
    events = Event.where(discussion_id: discussion_ids)
                  .order(sequence_id: :desc)
                  .group_by(&:discussion_id)
                  .map { |d, events| events.first }
  end
end
