class DiscussionTagSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id
  has_one :tag, serializer: TagSerializer
  has_one :discussion, serializer: DiscussionSerializer
end
