module Null::Group
  include Null::Object

  def group
    self
  end

  alias :read_attribute_for_serialization :send

  def new_threads_max_depth
    2
  end

  def new_threads_newest_first
    false
  end

  def full_name
    I18n.t('discussion.invite_only')
  end

  def name
    I18n.t('discussion.invite_only')
  end

  def nil_methods
    %w(
      parent
      id
      key
      locale
      update_polls_count
      update_closed_polls_count
      update_discussions_count
      update_public_discussions_count
      update_open_discussions_count
      update_closed_discussions_count
      presence
      present?
      content_locale
      handle
      description
      description_format
      group_id
      add_member!
      message_channel
      logo_or_parent_logo
      created_at
      creator_id
      cover_url
      logo_url
    )
  end

  def true_methods
    [:members_can_raise_motions, :members_can_edit_comments, :members_can_delete_comments, :discussion_private_default, :members_can_announce, :members_can_edit_discussions, :members_can_add_guests]
  end

  def empty_methods
    [:member_ids, :identities, :accepted_members]
  end

  def discussion_privacy_options
    'private_only'
  end

  def webhooks
    Webhook.none
  end
  def admins
    User.none
  end

  def members
    User.none
  end

  def memberships
    Membership.none
  end

  def false_methods
    %w(
      private_discussions_only?
      public_discussions_only?
      is_visible_to_parent_members
      members_can_add_members
      members_can_add_guests
      members_can_create_subgroups
      members_can_edit_discussions
      members_can_start_discussions
      admins_can_edit_user_content
    )
  end

  def zero_methods
    %w[
      memberships_count
      polls_count
      closed_polls_count
      discussions_count
      public_discussions_count
      pending_memberships_count
    ]
  end

  def none_methods
    {
      members: :user
    }
  end

  def group_privacy
    'private_only'
  end

  def parent_or_self
    self
  end

  def id_and_subgroup_ids
    []
  end

  def subscription
    {
      max_members:     nil,
      max_threads:     nil,
      active:          true,
      members_count:   0
    }
  end
end
