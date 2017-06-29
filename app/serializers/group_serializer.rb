class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :cohort_id,
             :key,
             :created_at,
             :creator_id,
             :members_can_add_members,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote,
             :motions_count,
             :closed_motions_count,
             :polls_count,
             :closed_polls_count,
             :proposal_outcomes_count,
             :discussions_count,
             :public_discussions_count,
             :announcement_recipients_count,
             :group_privacy,
             :memberships_count,
             :invitations_count,
             :pending_invitations_count,
             :membership_granted_upon,
             :discussion_privacy_options,
             :has_discussions,
             :has_multiple_admins,
             :archived_at,
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

  def has_discussions
    object.discussions_count > 0
  end

  def has_multiple_admins
    object.admin_memberships_count > 1
  end

end
