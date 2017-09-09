module Null::Group
  include Null::Object

  def group
    self
  end

  def parent_or_self
    self
  end

  alias :read_attribute_for_serialization :send

  def type
    "NullGroup"
  end

  def nil_methods
    [
      :id,
      :key,
      :name,
      :full_name,
      :description,
      :logo_url_medium,
      :created_at,
      :creator_id,
      :group_privacy,
      :membership_for,
      :membership_granted_upon,
      :discussion_privacy_options,
      :has_discussions,
      :has_multiple_admins,
      :archived_at,
      :update_polls_count,
      :update_closed_polls_count,
      :update_discussions_count,
      :update_public_discussions_count,
      :presence,
      :group_id,
      :cohort_id,
      :cohort,
      :parent_id,
      :parent,
      :add_member!,
      :_read_attribute
    ]
  end

  def false_methods
    [
      :marked_for_destruction?,
      :destroyed?,
      :parent_members_can_see_discussions?,
      :members_can_start_discussions?,
      :members_can_start_discussions,
      :members_can_add_members,
      :members_can_add_members?,
      :members_can_create_subgroups,
      :members_can_create_subgroups?,
      :members_can_edit_discussions,
      :members_can_edit_discussions?,
      :members_can_edit_comments,
      :members_can_edit_comments?,
      :members_can_raise_motions,
      :members_can_raise_motions?,
      :members_can_vote,
      :members_can_vote?,
      :new_record?
    ]
  end

  def zero_methods
    [
      :polls_count,
      :closed_polls_count,
      :discussions_count,
      :public_discussions_count,
      :announcement_recipients_count,
      :memberships_count,
      :invitations_count,
      :pending_invitations_count,
      :admin_memberships_count
    ]
  end

  def none_methods
    {
      members: :user
    }
  end
end
