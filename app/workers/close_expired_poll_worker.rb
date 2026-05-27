class CloseExpiredPollWorker
  include Sidekiq::Worker

  def perform(poll_id)
    poll = Poll.find(poll_id)
    return if poll.closed_at
    PollService.do_closing_work(poll: poll)
    Events::PollExpired.publish!(poll)
    PollService.publish_topic_if_active(poll)
  end
end
