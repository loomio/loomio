class PollDidNotVoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :poll_id

  has_one :user, root: :users
end
