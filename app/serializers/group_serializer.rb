class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :created_at,
             :description,
             :members_can_add_members,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote,
             :visible_to,
             :membership_granted_upon,
             :discussion_privacy_options,
             :logo_url_small,
             :cover_url_small

  has_one :parent, serializer: GroupSerializer, root: 'groups'

  def logo_url_small
    object.logo.url(:medium)
  end

  def cover_url_small
    object.cover_photo.url(:card)
  end

end
