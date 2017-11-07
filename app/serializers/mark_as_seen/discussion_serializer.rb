class MarkAsSeen::DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :seen_by_count
end
