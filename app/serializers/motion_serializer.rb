class MotionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :discussion_id,
             :name,
             :description,
             :outcome,
             :votes_count,
             :did_not_votes_count,
             :created_at,
             :updated_at,
             :closing_at,
             :closed_at,
             :last_vote_at,
             :vote_counts

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :outcome_author, serializer: UserSerializer, root: 'users'

  has_many :votes, serializer: VoteSerializer

  def filter(keys)
    keys.delete(:outcome_author) unless object.outcome_author.present?
    keys
  end
end
