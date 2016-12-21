class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :name, :description

  has_one :discussion, serializer: DiscussionSerializer
  has_one :author, serializer: UserSerializer, root: :users
end
