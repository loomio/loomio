module Null::Group
  include Null::Object

  def group
    self
  end

  def nil_methods
    [:name, :full_name, :id, :key, :update_polls_count, :update_closed_polls_count, :presence, :group_id, :add_member!,:message_channel]
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
