class MembershipSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :volume, :admin, :search_fragment
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :user, serializer: UserSerializer, root: 'users'
  has_one :inviter, serializer: UserSerializer, root: 'users'

  def search_fragment
    scope[:q]
  end

end
