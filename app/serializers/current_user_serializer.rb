class CurrentUserSerializer < UserSerializer
  attributes :dashboard_sort, :dashboard_filter, :notifications_last_viewed_at

  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
end
