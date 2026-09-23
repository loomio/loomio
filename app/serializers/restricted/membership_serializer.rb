class Restricted::MembershipSerializer < ApplicationSerializer
  embed :ids, include: true
  attributes :id, :user_id, :group_id
  has_one :group, serializer: Restricted::GroupSerializer, root: :groups
end
