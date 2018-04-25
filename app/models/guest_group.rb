class GuestGroup < Group

  delegate :update_undecided_user_count, to: :invitation_target, allow_nil: true

  def invitation_target
    Poll.find_by(guest_group_id: id)
  end

  def subgroups
    Group.none
  end

  def documents
    Document.none
  end

  def group_privacy=(term)
    raise 'guest groups cant be open' if term == 'open'
    super
  end
end
