class CloseExpiredPollWorker < ApplicationJob
  def perform(poll_id)
    poll = Poll.find(poll_id)
    PollService.do_closing_work(poll: poll) unless poll.closed_at

    publish_expiry(poll)
    PollService.publish_topic_if_active(poll)
  end

  private

  # A retry after the poll transaction committed must still repair a missing
  # notification. Direct notification identity makes this idempotent.
  def publish_expiry(poll)
    NotificationService.create!(
      kind: "poll_expired",
      subject: poll,
      actor: poll.author
    )
  end
end
