class Restricted::MembershipSerializer < ApplicationSerializer
  embed :ids, include: true
  attributes :id, :email_volume, :push_volume, :user_id, :group_id
  has_one :group, serializer: Restricted::GroupSerializer, root: :groups
end
