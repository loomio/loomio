class ResetPollStanceDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    p = Poll.find(poll_id)
    p.reset_latest_stances!
    p.update_voters_count
    p.update_undecided_voters_count
    p.update_stance_data
  end
end
