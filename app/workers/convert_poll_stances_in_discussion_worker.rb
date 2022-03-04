class ConvertPollStancesInDiscussionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    poll = Poll.find(poll_id)
    return if !poll.discussion_id
    return if poll.stances_in_discussion
    poll.update_attribute(:stances_in_discussion, true)
    stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
    Stance.where(id: stance_ids).each do |stance|
      stance.create_missing_created_event! if stance.created_event.nil?
    end
    Event.where(kind: 'stance_created', eventable_id: stance_ids, discussion_id: nil).update_all(discussion_id: poll.discussion_id)
    EventService.repair_thread(poll.discussion_id)
  end
end
