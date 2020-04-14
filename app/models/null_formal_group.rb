class NullGroup
  include Null::Group

  def initialize
    apply_null_methods!
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
