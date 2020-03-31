class Pending::DiscussionReaderSerializer < Pending::MembershipSerializer
  def identity_type
    :discussion_reader
  end
end
