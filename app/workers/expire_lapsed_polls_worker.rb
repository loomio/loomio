class ExpireLapsedPollsWorker < ApplicationJob
  def perform
    PollService.expire_lapsed_polls
  end
end
