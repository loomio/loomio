class MembershipSerializer < ActiveModel::Serializer
  include Concerns::BelongsToGroup

  embed :ids, include: true
  attributes :id, :volume, :admin, :experiences, :created_at

  has_one :user, serializer: UserSerializer, root: :users
  has_one :inviter, serializer: UserSerializer, root: :users

  def include_inviter?
    [nil, true].include? (scope || {})[:include_inviter]
  end
end
