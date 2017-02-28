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
             :members_can_raise_motions,
             :members_can_vote,
             :motions_count,
             :closed_motions_count,
             :closed_polls_count,
             :proposal_outcomes_count,
             :discussions_count,
             :public_discussions_count,
             :announcement_recipients_count,
             :group_privacy,
             :is_visible_to_parent_members,
             :parent_members_can_see_discussions,
             :memberships_count,
             :invitations_count,
             :pending_invitations_count,
             :membership_granted_upon,
             :discussion_privacy_options,
             :logo_url_medium,
             :cover_urls,
             :has_discussions,
             :has_multiple_admins,
             :archived_at,
             :has_custom_cover,
             :is_subgroup_of_hidden_parent,
             :enable_experiments,
             :experiences,
             :features,
             :recent_activity_count

  has_one :current_user_membership, serializer: MembershipSerializer, root: :memberships

  has_one :parent, serializer: GroupSerializer, root: :groups

  private

  def current_user_membership
    @current_user_membership ||= object.membership_for(scope[:current_user])
  end

  def include_current_user_membership?
    scope && scope[:current_user]
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.logo.present?
  end

  def cover_urls
    {
      small:  cover_photo.url(:card),
      medium: cover_photo.url(:desktop),
      large:  cover_photo.url(:largedesktop)
    }
  end

  def has_custom_cover
    cover_photo.present?
  end

  def has_discussions
    object.discussions_count > 0
  end

  def has_multiple_admins
    object.admin_memberships_count > 1
  end

  def cover_photo
    @cover_photo ||= object.cover_photo
  end

  def is_subgroup_of_hidden_parent
    object.is_subgroup_of_hidden_parent?
  end
end
