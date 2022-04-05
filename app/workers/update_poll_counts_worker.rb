class UpdatePollCountsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    p = Poll.find(poll_id)
    p.update_counts!
  end
end
