class ExpireLapsedPollsWorker < ApplicationJob
  limits_concurrency key: 'expire_lapsed_polls', on_conflict: :discard

  def perform
    PollService.expire_lapsed_polls
  end
end
