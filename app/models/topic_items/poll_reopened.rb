class TopicItems::PollReopened < TopicItem
  def self.publish!(poll, actor)
    create(kind: "poll_reopened",
           user: actor,
           topic: poll.topic,
           itemable: poll).tap { |e| EventBus.broadcast('poll_reopened_event', e) }
  end
end
