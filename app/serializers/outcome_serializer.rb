class OutcomeSerializer < ActiveModel::Serializer
  attributes :id, :statement

  has_one :poll, serializer: PollSerializer
  has_one :author, serializer: UserSerializer
end
