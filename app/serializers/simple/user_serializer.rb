class Simple::UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :name, :username
end
