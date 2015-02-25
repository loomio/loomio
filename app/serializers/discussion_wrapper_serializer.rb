class DiscussionWrapperSerializer < ActiveModel::Serializer
  embed :ids, include: true

  has_one :discussion, serializer: DiscussionSerializer, root: 'discussions'
  has_one :discussion_reader, serializer: DiscussionReaderSerializer, root: 'discussion_readers'
end
