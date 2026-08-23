class TopicItems::StanceCreated < TopicItem
  include TopicItems::Notify::Chatbots
  include TopicItems::Notify::Subscribers
  include TopicItems::LiveUpdate

  def self.publish!(stance)
    raise ArgumentError, "stance must be eligible for the topic timeline" unless stance.add_to_thread?

    participant = stance.participant.presence
    publish_and_mark_read!(stance,
                           reader: participant,
                           user: participant,
                           topic: stance.poll.topic)
  end

  def real_user
    itemable.real_participant
  end
end
