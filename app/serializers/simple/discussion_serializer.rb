class Simple::DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :title
end
