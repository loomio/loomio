class NullFormalGroup
  include Null::Group

  def initialize
    apply_null_methods!
  end
end
