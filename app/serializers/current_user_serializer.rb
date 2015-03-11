class CurrentUserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  has_one :user, serializer: UserSerializer
  has_many :memberships, serializer: MembershipSerializer, root: 'memberships'

  def user
    object
  end
end
