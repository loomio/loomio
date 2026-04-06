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
    topic_id = poll.discussion&.topic&.id
    Event.where(kind: 'stance_created', eventable_id: stance_ids, topic_id: nil).update_all(topic_id: topic_id) if topic_id
    EventService.repair_thread(poll.discussion.topic) if poll.discussion&.topic
  end
end
