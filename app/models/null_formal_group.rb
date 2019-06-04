class NullFormalGroup
  include Null::Group

  def initialize
    apply_null_methods!
  end

  def cover_photo
    FormalGroup.new.cover_photo
  end

  def logo
    FormalGroup.new.logo
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

  def guest_group
    self
  end
end
