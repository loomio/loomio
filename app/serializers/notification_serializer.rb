class NotificationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :viewed, :created_at, :url, :kind, :translation_values

  has_one :actor, serializer: UserSerializer, root: :users
end
