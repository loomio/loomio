class OpenScheduledPollsWorker < ApplicationJob
  limits_concurrency key: 'open_scheduled_polls', on_conflict: :discard

  def perform
    PollService.open_scheduled_polls
  end
end
