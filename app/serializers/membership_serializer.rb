class MembershipSerializer < ActiveModel::Serializer

  has_one :group, serializer: GroupSerializer, root: :groups

  embed :ids, include: true
  attributes :id, :volume, :admin, :experiences, :title, :created_at, :accepted_at, :saml_session_expires_at

  has_one :user, serializer: UserSerializer, root: :users
  has_one :inviter, serializer: UserSerializer, root: :users

  def include_inviter?
    [nil, true].include? (scope || {})[:include_inviter]
  end
end
