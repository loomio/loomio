class MotionSerializer < ActiveModel::Serializer
  attributes :id,
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
             :last_vote_at

  has_one :author, serializer: AuthorSerializer
  has_one :outcome_author, serializer: AuthorSerializer
end
