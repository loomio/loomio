class Restricted::MembershipSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :volume, :user_id
  has_one :group, serializer: Restricted::GroupSerializer, root: :groups
end
