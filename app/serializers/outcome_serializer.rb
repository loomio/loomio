class OutcomeSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :statement, :latest

  has_one :poll, serializer: PollSerializer
  has_one :author, serializer: UserSerializer
end
