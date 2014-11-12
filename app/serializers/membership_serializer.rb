class MembershipSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :user, serializer: UserSerializer, root: 'users'
end
