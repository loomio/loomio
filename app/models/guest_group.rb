class GuestGroup < Group
  delegate :update_undecided_count, to: :target_model, allow_nil: true

  def id_and_subgroup_ids
    Array(id)
  end

  def group_privacy=(term)
    raise 'guest groups cant be open' if term == 'open'
    super
  end
end
