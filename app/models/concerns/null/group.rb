module Null::Group
  include Null::Object

  def group
    self
  end

  def nil_methods
    [:id, :update_polls_count, :presence, :group_id]
  end

  def none_methods
    {
      members: :user
    }
  end
end
