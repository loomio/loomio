class CurrentUserSerializer < UserSerializer
  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
end
