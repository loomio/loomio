class GroupSerializer < ApplicationSerializer
  attributes :id,
             :key,
             :handle,
             :name,
             :full_name,
             :description,
             :description_format,
             :logo_url_medium,
             :created_at,
             :creator_id,
             :members_can_add_members,
             :members_can_announce,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :admins_can_edit_user_content,
             :token,
             :polls_count,
             :closed_polls_count,
             :discussions_count,
             :public_discussions_count,
             :group_privacy,
             :memberships_count,
             :pending_memberships_count,
             :active_memberships_count,
             :announceable_members_count,
             :membership_granted_upon,
             :discussion_privacy_options,
             :has_discussions,
             :admin_memberships_count,
             :archived_at,
             :attachments,
             :tag_names,
             :new_threads_max_depth,
             :new_threads_newest_first,
             :cover_urls,
             :has_custom_cover,
             :experiences,
             :enable_experiments,
             :features,
             :open_discussions_count,
             :closed_discussions_count,
             :recent_activity_count,
             :is_visible_to_public,
             :is_subgroup_of_hidden_parent,
             :is_visible_to_parent_members,
             :parent_members_can_see_discussions,
             :org_memberships_count,
             :org_discussions_count,
             :org_members_count,
             :subscription,
             :subgroups_count,
             :complete,
             :secret_token

  def complete
    true
  end

  has_one :parent, serializer: GroupSerializer, root: :parent_groups
  has_one :current_user_membership, serializer: MembershipSerializer, root: :memberships

  def current_user_membership
    scope && scope[:current_user] && object.membership_for(scope[:current_user])
  end

  def subscription
    sub = Subscription.for(object)
    if (current_user_membership && sub)
      {
        max_members:     sub.max_members,
        max_threads:     sub.max_threads,
        plan:            sub.plan,
        active:          sub.is_active?,
        renews_at:       sub.renews_at,
        expires_at:      sub.expires_at,
        management_link: (sub.info || {})['chargify_management_link'],
        referral_code:   (sub.info || {})['chargify_referral_code'],
        members_count:   sub.members_count
      }
    else
      {
        max_members:     sub.max_members,
        max_threads:     sub.max_threads,
        active:          sub.is_active?,
        members_count:   sub.members_count
      }
    end
  end

  def include_current_user_membership?
    super && scope[:current_user]
  end

  def include_secret_token?
    current_user_membership && current_user_membership.admin
  end

  def tag_names
    object.info['tag_names'] || []
  end

  def cover_photo
    @cover_photo ||= object.cover_photo
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def cover_urls
    {
      small:      cover_photo.url(:desktop),
      medium:     cover_photo.url(:largedesktop),
      large:      cover_photo.url(:largedesktop),
      extralarge: cover_photo.url(:largedesktop)
    }
  end

  def has_custom_cover
    cover_photo.present?
  end

  def is_subgroup_of_hidden_parent
    object.is_subgroup_of_hidden_parent?
  end

  private
  def include_logo_url_medium?
    object.logo.present?
  end

  def include_org_memberships_count?
    object.is_parent?
  end

  def include_token?
    Hash(scope)[:include_token]
  end

  def has_discussions
    object.discussions_count > 0
  end
end
