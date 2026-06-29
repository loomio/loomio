class PublishClosingSoonWorker < ApplicationJob
  def perform
    PollService.publish_closing_soon
  end
end
