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

  def nil_methods
    %w(
      parent
      name
      full_name
      id
      key
      update_polls_count
      update_closed_polls_count
      update_discussions_count
      update_public_discussions_count
      update_open_discussions_count
      update_closed_discussions_count
      presence
      handle
      description
      description_format
      group_id
      add_member!
      message_channel
    )
  end

  def true_methods
    [:members_can_vote, :members_can_raise_motions]
  end

  def empty_methods
    [:member_ids, :members, :admins, :webhooks, :identities, :accepted_members]
  end

  def false_methods
    %w(
      private_discussions_only?
      public_discussions_only?
      is_visible_to_parent_members
    )
  end

  def zero_methods
    [:memberships_count]
  end

  def none_methods
    {
      members: :user
    }
  end

  def cover_photo
    Group.new.cover_photo
  end

  def logo
    Group.new.logo
  end

  def parent_or_self
    self
  end

  def id_and_subgroup_ids
    []
  end
end
