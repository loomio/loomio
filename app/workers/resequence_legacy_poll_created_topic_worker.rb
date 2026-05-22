class ResequenceLegacyPollCreatedTopicWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(topic_id)
    TopicService.resequence_chronologically(topic_id)
  end
end
