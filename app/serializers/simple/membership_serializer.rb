class Simple::MembershipSerializer < ActiveModel::Serializer
  embed :ids, include: true

  has_one :group, serializer: Simple::GroupSerializer, root: :groups
  has_one :user, serializer: UserSerializer, root: :users

  attributes :id, :volume, :admin, :experiences, :created_at, :accepted_at, :saml_session_expires_at
end
