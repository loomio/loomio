class RepairTopicWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(topic_id)
    TopicService.repair(topic_id)
  end
end
