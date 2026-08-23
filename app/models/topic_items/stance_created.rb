class TopicItems::StanceCreated < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(stance)
    raise ArgumentError, "stance must be eligible for the topic timeline" unless stance.add_to_thread?

    super(stance,
          user: stance.participant.presence,
          topic: stance.poll.topic)
  end

  def real_user
    itemable.real_participant
  end
end
