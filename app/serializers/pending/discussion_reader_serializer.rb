class Pending::DiscussionReaderSerializer < Pending::MembershipSerializer
  def auth_form
    false
  end
  
  def identity_type
    :discussion_reader
  end

  def group_id
    nil
  end
end
