class CloseExpiredPollWorker < ApplicationJob
  limits_concurrency key: ->(poll_id) { poll_id }, on_conflict: :discard

  def perform(poll_id)
    poll = Poll.find_by(id: poll_id)
    return unless poll

    PollService.expire(poll: poll)
  end
end
