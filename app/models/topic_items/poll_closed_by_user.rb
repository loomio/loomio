class TopicItems::PollClosedByUser < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::LiveUpdate

end
