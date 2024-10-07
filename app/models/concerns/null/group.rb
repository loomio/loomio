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
    I18n.t('discussion.direct_thread')
  end

  def save
    true
  end
  
  def name
    I18n.t('discussion.direct_thread')
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
      update_discussion_templates_count
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
      category
    )
  end

  def true_methods
    %w[
      private_discussions_only?
      members_can_raise_motions
      members_can_edit_comments
      members_can_delete_comments
      discussion_private_default
      members_can_announce
      members_can_edit_discussions
      members_can_add_guests
    ]
  end

  def empty_methods
    %w[
      member_ids
      identities
      hidden_poll_templates
      hidden_discussion_templates
    ]
  end

  def discussion_privacy_options
    'private_only'
  end

  def false_methods
    %w(
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
      discussion_templates_count
    ]
  end

  def none_methods
    {
      members: :user,
      self_and_subgroups: :group,
      accepted_members: :user,
      chatbots: :chatbot,
      tags: :tag,
      poll_templates: :poll_template,
      discussion_templates: :discussion_template,
      memberships: :membership,
      admins: :user,
      webhooks: :webhook,
    }
  end

  def discussion_templates=(arg)
    nil
  end
  
  def group_privacy
    'private_only'
  end

  def parent_or_self
    self
  end
  
  def self_or_parent_logo_url(size)
    nil
  end

  def self_or_parent_cover_url(size)
    nil
  end

  def id_and_subgroup_ids
    []
  end

  def poll_template_positions
    {
      'question' => 0,
      'check' => 1,
      'advice' => 2,
      'consent' => 3,
      'consensus' => 4,
      'gradients_of_agreement' => 5,
      'poll' => 6,
      'score' => 7,
      'dot_vote' => 8,
      'ranked_choice' => 9,
      'meeting' => 10,
      'count' => 11,
    }
  end

  def discussion_template_positions
    {
      'blank' => 0,
      'open_discussion' => 1,
      'updates_thread' => 2,
    }
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
