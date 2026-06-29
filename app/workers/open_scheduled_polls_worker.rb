class OpenScheduledPollsWorker < ApplicationJob
  def perform
    PollService.open_scheduled_polls
  end
end
