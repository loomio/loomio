class DocumentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :title, :icon, :color, :url, :model_id, :model_type, :attachment_id, :created_at
  has_one :author, serializer: Simple::UserSerializer, root: :users
end
