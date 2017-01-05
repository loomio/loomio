class StanceSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reason, :score, :latest, :mentioned_usernames, :created_at

  has_one :poll_option, serializer: PollOptionSerializer
  has_one :poll, serializer: PollSerializer
  has_one :participant, serializer: UserSerializer, root: :users
end
