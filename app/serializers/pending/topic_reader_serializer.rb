class Pending::TopicReaderSerializer < Pending::MembershipSerializer
  def identity_type
    :topic_reader
  end

  def group_id
    nil
  end
end
