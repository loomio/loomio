class ContactSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :name,
             :email,
             :source

  has_one :user, serializer: UserSerializer, root: :users
end
