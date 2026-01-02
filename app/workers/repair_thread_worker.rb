class RepairThreadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(discussion_id)
    EventService.repair_discussion(discussion_id)
  end
end
