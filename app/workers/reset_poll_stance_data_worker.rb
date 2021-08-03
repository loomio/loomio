class ResetPollStanceDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    p = Poll.find(poll_id)
    p.reset_latest_stances!
    p.stances.latest.each(&:update_counts!)
    p.update_counts!
  end
end
