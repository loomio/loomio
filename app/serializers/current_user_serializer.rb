class CurrentUserSerializer < UserSerializer
  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'
  attributes :email

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end

end
