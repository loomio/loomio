class NotificationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :viewed, :created_at
  has_one :event, serializer: EventSerializer, root: 'events'
end
