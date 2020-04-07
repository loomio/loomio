class GuestGroup < Group

  def is_parent?
    false
  end

  def id_and_subgroup_ids
    Array(id)
  end

  def subgroups
    Group.none
  end

  def group_privacy=(term)
    raise 'guest groups cant be open' if term == 'open'
    super
  end
end
