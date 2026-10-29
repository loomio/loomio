class OpenScheduledPollWorker < ApplicationJob
  limits_concurrency key: ->(poll_id) { poll_id }, on_conflict: :discard

  def perform(poll_id)
    poll = Poll.find_by(id: poll_id)
    return unless poll

    if PollService.open_poll_if_ready(poll)
      PollService.publish_topic_if_active(poll)
    end
  end
end
