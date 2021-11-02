class RepairThreadWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(discussion_id)
    EventService.repair_thread(discussion_id)
  end
end
