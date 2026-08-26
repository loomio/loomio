class CloseExpiredPollWorker < ApplicationJob
  def perform(poll_id)
    poll = Poll.find(poll_id)
    PollService.do_closing_work(poll: poll) unless poll.closed_at

    publish_expiry(poll)
    PollService.publish_topic_if_active(poll)
  end

  private

  # A poll can be reopened and expire again. Treat an expiry notification made
  # after the current closing_at as belonging to this closing.
  def publish_expiry(poll)
    return if Notification.where(kind: "poll_expired", subject: poll)
                          .where(created_at: poll.closing_at..)
                          .exists?

    NotificationService.create!(
      kind: "poll_expired",
      subject: poll,
      actor: poll.author
    )
  end
end
