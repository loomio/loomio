class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :organisation_id,
             :cohort_id,
             :key,
             :name,
             :full_name,
             :created_at,
             :creator_id,
             :description,
             :members_can_add_members,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_proposals,
             :members_can_vote,
             :memberships_count,
             :members_count,
             :visible_to,
             :membership_granted_upon,
             :discussion_privacy_options,
             :logo_url_medium,
             :cover_url_desktop,
             :has_discussions,
             :has_multiple_admins,
             :archived_at,
             :has_custom_cover,
             :subscription_kind,
             :subscription_plan,
             :subscription_expires_at

  has_one :parent, serializer: GroupSerializer, root: 'groups'

  def subscription_kind
    object.subscription.try(:kind)
  end

  def subscription_plan
    object.subscription.try(:plan)
  end

  def subscription_expires_at
    object.subscription.try(:expires_at)
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.logo.present?
  end

  def cover_url_desktop
    object.cover_photo.url(:desktop)
  end

  def has_custom_cover
    object.cover_photo.present?
  end

  def members_can_raise_proposals
    object.members_can_raise_motions
  end

  def has_discussions
    object.discussions_count > 0
  end

  def has_multiple_admins
    object.admins.count > 1
  end
end
