class UpdatePollCountsWorker < ApplicationJob
  queue_as :low

  def perform(poll_id)
    p = Poll.find(poll_id)
    p.update_counts!
  end
end
