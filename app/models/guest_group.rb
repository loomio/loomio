class GuestGroup < Group

  def invitation_target
    Poll.find_by(guest_group_id: id)
  end

  def group_privacy=(term)
    raise 'guest groups cant be open' if term == 'open'
    super
  end
end
