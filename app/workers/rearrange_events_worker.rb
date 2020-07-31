class RearrangeEventsWorker
  include Sidekiq::Worker

  def perform(discussion_id)
    discussion = Discussion.find_by(id: discussion_id)
    return unless discussion
    discussion.update_sequence_info!
    EventService.reposition_events(discussion)
  end
end
