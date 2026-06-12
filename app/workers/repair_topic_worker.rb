class RepairTopicWorker < ApplicationJob
  def perform(topic_id)
    TopicService.repair(topic_id)
  end
end
