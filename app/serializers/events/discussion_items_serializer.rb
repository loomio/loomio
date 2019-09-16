class Events::DiscussionItemsSerializer < ActiveModel::Serializer
  embed :ids, include: true
  has_many :items, root: :events
end
