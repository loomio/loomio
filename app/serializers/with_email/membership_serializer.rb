class WithEmail::MembershipSerializer < MembershipSerializer
  has_one :user, serializer: WithEmail::UserSerializer, root: :users
end
