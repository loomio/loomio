class DiscussionTagSerializer < ApplicationSerializer
  attributes :id, :discussion_id
  has_one :tag, serializer: TagSerializer
  has_one :discussion, serializer: DiscussionSerializer
end
