class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :created_at,
             :description,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote,
             :members_can_start_discussions,
             :discussion_privacy_options,
             :visible_to

  has_one :parent, serializer: GroupSerializer, root: 'groups'
end
