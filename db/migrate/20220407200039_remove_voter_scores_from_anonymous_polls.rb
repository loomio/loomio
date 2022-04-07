class RemoveVoterScoresFromAnonymousPolls < ActiveRecord::Migration[6.1]
  def change
    Poll.where(anonymous: true).each do |p|
      UpdatePollCountsWorker.perform_async(p.id)
    end
  end
end
