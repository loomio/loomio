class Full::PollSerializer < ::PollSerializer
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
end
