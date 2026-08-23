class TopicItems::DiscussionEdited < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::LiveUpdate

  def self.publish!(discussion:, actor:)
    super(discussion,
          user: actor,
          topic: discussion.topic)
  end

  def discussion
    itemable
  end
end
