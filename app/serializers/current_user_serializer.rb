class CurrentUserSerializer < UserSerializer
  attributes :dashboard_sort, :dashboard_filter

  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
end
