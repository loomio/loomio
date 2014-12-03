class CurrentUserSerializer < ActiveModel::Serializer
  # the current user will also be serialized into the users array, so we just
  # include other seed data here
  embed :ids, include: true
  attributes :id

  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
end
