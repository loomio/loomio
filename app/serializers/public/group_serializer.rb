class Public::GroupSerializer < ActiveModel::Serializer

  attributes :organisation_id,
             :key,
             :parent_key,
             :name,
             :description,
             :created_at,
             :members_can_add_members,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote,
             :members_count,
             :membership_granted_upon,
             :logo_url_medium,
             :cover_url_desktop,
             :archived_at

  def parent_key
    object.parent.try(:key)
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

  def include_cover_url_desktop?
    object.cover_photo.present?
  end

end
