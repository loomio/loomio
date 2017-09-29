class DocumentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :title, :icon, :color, :url, :model_id, :model_type, :created_at
  has_one :author, serializer: UserSerializer, root: :users
end
