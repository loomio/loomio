module Null::Group
  include Null::Object

  def nil_methods
    [:update_polls_count, :presence]
  end

  def none_methods
    {
      members: :user
    }
  end
end
