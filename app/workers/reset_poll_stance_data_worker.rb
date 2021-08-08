class ResetPollStanceDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    p = Poll.find(poll_id)
    p.reset_latest_stances!
    p.stances.each(&:update_option_scores!)
    p.update_counts!
  end
end
