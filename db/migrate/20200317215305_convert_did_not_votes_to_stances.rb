class ConvertDidNotVotesToStances < ActiveRecord::Migration[5.2]
  def change
    execute "INSERT INTO stances (poll_id, participant_id, created_at) (SELECT poll_did_not_votes.poll_id as poll_id, poll_did_not_votes.user_id as participant_id, polls.created_at as created_at FROM poll_did_not_votes JOIN polls ON poll_did_not_votes.poll_id = polls.id)"
  end
end
