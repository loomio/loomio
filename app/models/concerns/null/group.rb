module Null::Group
  include Null::Object

  def group
    self
  end

  def nil_methods
    [:parent, :name, :full_name, :id, :key, :update_polls_count, :update_closed_polls_count, :presence, :group_id, :add_member!,:message_channel]
  end

  def true_methods
    [:members_can_vote, :members_can_raise_motions]
  end

  def empty_methods
    [:member_ids, :members, :admins, :webhooks]
  end

  def false_methods
    [:is_visible_to_parent_members]
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

  def identities
    Identities::Base.none
  end
end
