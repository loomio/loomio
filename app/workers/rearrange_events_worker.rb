class RearrangeEventsWorker
  include Sidekiq::Worker

  def perform(discussion_id)
    @discussion = Discussion.find(discussion_id)
    EventService.rearrange_events(@discussion)
  end
end
