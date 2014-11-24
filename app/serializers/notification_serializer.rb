class NotificationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id

  has_one :user, serializer: UserSerializer, root: 'users'
  has_one :event, serializer: EventSerializer, root: 'events'

end
