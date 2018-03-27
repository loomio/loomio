class GuestGroup < Group

  # pass this through to poll
  def update_undecided_user_count
    Poll.find_by(guest_group_id: id)&.update_undecided_user_count
  end

  def group_privacy=(term)
    raise 'guest groups cant be open' if term == 'open'
    super
  end
end
