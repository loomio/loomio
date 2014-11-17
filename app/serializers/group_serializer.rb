class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :created_at,
             :description,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote


  has_one :parent, serializer: GroupSerializer, root: 'groups'
end
