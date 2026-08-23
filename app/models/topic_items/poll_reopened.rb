class TopicItems::PollReopened < TopicItem
  def self.publish!(poll, actor)
    create(kind: "poll_reopened",
           user: actor,
           topic: poll.topic,
           itemable: poll)
  end
end
