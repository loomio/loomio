class Events::ArraySerializer < ActiveModel::Serializer
  embed :ids, include: true
  has_many :events, root: :events
end
