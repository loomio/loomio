class RepairThreadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(topic_id)
    TopicService.repair_thread(topic_id)
  end
end
