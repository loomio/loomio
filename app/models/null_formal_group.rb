class NullFormalGroup
  include Null::Group

  def initialize
    apply_null_methods!
  end

  def identities
    Identities::Base.none
  end
end
