class ResequenceLegacyPollCreatedTopicWorker < ApplicationJob
  def perform(topic_id)
    TopicService.resequence_chronologically(topic_id)
  end
end
