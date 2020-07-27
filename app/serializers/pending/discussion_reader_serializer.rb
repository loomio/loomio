class Pending::DiscussionReaderSerializer < Pending::MembershipSerializer
  def identity_type
    :discussion_reader
  end

  def group_id
    nil
  end
end
