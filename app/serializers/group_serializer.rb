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
             :flexible_discussion_privacy,
             :allow_public_discussions

  def flexible_discussion_privacy
    object.discussion_privacy_options == 'public_or_private_discussions' && !is_visible_to_parent_members?
  end

  def allow_public_discussions
    object.discussion_privacy_options != 'private_only'
  end

  has_one :parent, serializer: GroupSerializer, root: 'groups'
end
