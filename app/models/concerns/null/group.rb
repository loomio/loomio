module Null::Group
  include Null::Object

  def group
    self
  end

  def nil_methods
    [:name, :full_name, :id, :key, :update_polls_count, :update_closed_polls_count, :presence, :group_id, :add_member!,:message_channel]
  end

  def true_methods
    [:members_can_vote, :members_can_raise_motions]
  end

  def empty_methods
    [:member_ids, :members, :admins]
  end

  def zero_methods
    [:memberships_count]
  end

  def none_methods
    {
      members: :user
    }
  end
end
