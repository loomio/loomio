class NullFormalGroup
  include Null::Group

  def self.primary_key
    :id
  end

  def self.base_class
    FormalGroup
  end

  def initialize
    apply_null_methods!
  end

  def identities
    Identities::Base.none
  end
end
