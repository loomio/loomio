class RepairThreadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(topic_or_discussion_id)
    # Support both topic_id and discussion_id for backwards compatibility
    topic = Topic.find_by(id: topic_or_discussion_id)
    unless topic
      discussion = Discussion.find_by(id: topic_or_discussion_id)
      topic = discussion&.topic
    end
    EventService.repair_thread(topic) if topic
  end
end
