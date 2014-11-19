#proposal.json.jbuilder
json.(proposal,
      :id,
      :discussion_id,
      :name,
      :description,
      :outcome,
      :votes_count,
      :yes_votes_count,
      :no_votes_count,
      :abstain_votes_count,
      :block_votes_count,
      :did_not_votes_count,
      :created_at,
      :updated_at,
      :closing_at,
      :closed_at,
      :last_vote_at)

json.author do
 json.partial! 'api/users/author', author: proposal.author
end

if proposal.outcome.present?
  json.outcome_author do
   json.partial! 'api/users/author', author: proposal.outcome_author
  end
end

