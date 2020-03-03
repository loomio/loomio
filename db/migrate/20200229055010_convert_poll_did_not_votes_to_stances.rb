class ConvertPollDidNotVotesToStances < ActiveRecord::Migration[5.2]
  def change
    stances = []
    PollDidNotVote.find_each do |dnv|
      stances << Stance.new(
        poll_id: dnv.poll_id,
        participant_id: dnv.user_id,
        created_at: poll.created_at,
        updated_at: poll.updated_at
      )
    end
    Stance.import(stances)
  end
end
