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
             :discussions_count,
             :public_discussions_count,
             :group_privacy,
             :is_visible_to_parent_members,
             :parent_members_can_see_discussions,
             :memberships_count,
             :invitations_count,
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
             :subscription_payment_method,
             :subscription_expires_at,
             :is_subgroup_of_hidden_parent,
             :show_legacy_trial_expired_modal,
             :enable_experiments

  has_one :current_user_membership, serializer: MembershipSerializer, root: :memberships

  has_one :parent, serializer: GroupSerializer, root: :groups

  private

  def current_user_membership
    @current_user_membership ||= object.membership_for(scope[:current_user])
  end

  def include_current_user_membership?
    scope && scope[:current_user]
  end

  def show_legacy_trial_expired_modal
    ENV['TRIAL_EXPIRED_GROUP_IDS'].to_s.split(' ').map(&:to_i).include? object.id
  end

  def subscription_kind
    subscription.try(:kind)
  end

  def subscription_plan
    subscription.try(:plan)
  end

  def subscription_payment_method
    subscription.try(:payment_method)
  end

  def subscription_expires_at
    subscription.try(:expires_at)
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.logo.present?
  end

  def cover_url_desktop
    cover_photo.url(:desktop)
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

  def subscription
    @subscription ||= object.subscription
  end

  def cover_photo
    @cover_photo ||= object.cover_photo
  end

  def is_subgroup_of_hidden_parent
    object.is_subgroup_of_hidden_parent?
  end
end
