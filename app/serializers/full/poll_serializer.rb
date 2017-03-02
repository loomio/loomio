class Full::PollSerializer < ::PollSerializer
  attributes :anyone_can_participate
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
end
