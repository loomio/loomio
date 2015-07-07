class CurrentUserSerializer < UserSerializer
  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
  attributes :email

  def include_gravatar_md5?
    true
  end
end
