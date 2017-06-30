class GuestGroup < Group
  def invitation_target
    Poll.find_by(guest_group_id: id)
  end
end
