class MembershipRequestSerializer < ApplicationSerializer
  attributes :id, :group_id, :name, :email, :introduction, :responded_at, :response, :created_at, :updated_at

  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :responder, serializer: UserSerializer, root: :users
  has_one :requestor, serializer: UserSerializer, root: :users
end
